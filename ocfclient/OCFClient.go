package Ocfclient

import (
	"context"
	"time"

	"github.com/plgd-dev/device/app"
	"github.com/plgd-dev/device/client"
	"github.com/plgd-dev/device/client/core"
	"github.com/plgd-dev/device/schema"
	"github.com/plgd-dev/device/schema/acl"
	"github.com/plgd-dev/device/schema/cloud"
	pbCA "github.com/plgd-dev/hub/certificate-authority/pb"
	caSigner "github.com/plgd-dev/hub/certificate-authority/signer"
	pbGRPC "github.com/plgd-dev/hub/grpc-gateway/pb"
	grpcCloud "github.com/plgd-dev/hub/pkg/net/grpc"
	"github.com/plgd-dev/kit/v2/codec/json"
	"github.com/plgd-dev/kit/v2/security"
	"google.golang.org/grpc"
	"google.golang.org/grpc/credentials"
	"google.golang.org/protobuf/encoding/protojson"
)

type (
	// Ocfclient for working with devices
	Ocfclient struct {
		client           *client.Client
		hubConfiguration pbGRPC.HubConfigurationResponse
		caClient         pbCA.CertificateAuthorityClient
	}
)

// Initialize creates and initializes new local client
func (c *Ocfclient) Initialize(accessToken, cloudConfiguration, signingServerAddress string) error {
	u := protojson.UnmarshalOptions{
		DiscardUnknown: true,
	}
	err := u.Unmarshal([]byte(cloudConfiguration), &c.hubConfiguration)
	if err != nil {
		return err
	}
	appCallback, err := app.NewApp(&app.AppConfig{
		RootCA: lets + "\n" + c.hubConfiguration.GetCertificateAuthorities(),
	})
	if err != nil {
		return err
	}

	rootCA, err := appCallback.GetRootCertificateAuthorities()
	if err != nil {
		return err
	}

	conn, err := grpc.Dial(signingServerAddress, grpc.WithTransportCredentials(credentials.NewTLS(security.NewDefaultTLSConfig(rootCA))))
	if err != nil {
		return err
	}
	c.caClient = pbCA.NewCertificateAuthorityClient(conn)
	signer := caSigner.NewIdentityCertificateSigner(c.caClient)

	localClient, err := client.NewClientFromConfig(&client.Config{
		DisablePeerTCPSignalMessageCSMs:   true,
		KeepAliveConnectionTimeoutSeconds: 10,
		ObserverPollingIntervalSeconds:    1,
		DeviceCacheExpirationSeconds:      3600,
		MaxMessageSize:                    512 * 1024,
		DeviceOwnershipBackend: &client.DeviceOwnershipBackendConfig{
			JWTClaimOwnerID: c.hubConfiguration.GetJwtOwnerClaim(),
			Sign:            signer.Sign,
		},
	}, appCallback, nil, func(err error) {})

	if err != nil {
		return err
	}

	ctx, cancel := context.WithTimeout(context.Background(), 4*time.Second)
	defer cancel()
	ctx = grpcCloud.CtxWithToken(ctx, accessToken)
	err = localClient.Initialization(ctx)
	if err != nil {
		return err
	}

	c.client = localClient
	return nil
}

func (c *Ocfclient) Close() error {
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()
	return c.client.Close(ctx)
}

func (c *Ocfclient) GetOwnerID() (string, error) {
	return c.client.CoreClient().GetSdkOwnerID()
}

// Discover devices in the local area
func (c *Ocfclient) Discover(timeoutSeconds int) (string, error) {
	ctx, cancel := context.WithTimeout(context.Background(), time.Duration(timeoutSeconds)*time.Second)
	defer cancel()
	res, err := c.client.GetDevices(ctx)
	if err != nil {
		return "", err
	}

	devices := []client.DeviceDetails{}
	for _, device := range res {
		if device.IsSecured {
			devices = append(devices, device)
		}
	}

	devicesJSON, err := json.Encode(devices)
	if err != nil {
		return "", err
	}
	return string(devicesJSON), nil
}

func getHubConfiguration(ctx context.Context, device *core.Device, links schema.ResourceLinks) (out interface{}, _ error) {
	var link schema.ResourceLink
	for _, l := range links {
		for _, rt := range l.ResourceTypes {
			if rt == cloud.ConfigurationResourceType {
				link = l
				break
			}
		}
	}

	var cloudConfiguration cloud.Configuration
	err := device.GetResource(ctx, link, &cloudConfiguration)
	if err != nil {
		return &err, nil
	}
	return &cloudConfiguration, nil
}

// GetResource retrieves, encodes and returns resource representation of specified resource
func (c *Ocfclient) GetResource(deviceID, resourceHref string) (string, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 3*time.Second)
	defer cancel()
	var data interface{}
	err := c.client.GetResource(ctx, deviceID, resourceHref, &data)
	if err != nil || data == nil {
		return "", err
	}

	dataJSON, err := json.Encode(data)
	if err != nil {
		return "", err
	}
	return string(dataJSON), nil
}

// OwnDevice transfers the ownersip of the device to user represented by the token
func (c *Ocfclient) OwnDevice(deviceID, accessToken string) (string, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 20*time.Second)
	defer cancel()
	ctx = grpcCloud.CtxWithToken(ctx, accessToken)
	return c.client.OwnDevice(ctx, deviceID, client.WithOTM(client.OTMType_JustWorks))
}

// SetAccessForCloud sets required ACL for the Cloud
func (c *Ocfclient) SetAccessForCloud(deviceID string) error {
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()
	d, links, err := c.client.GetRefDevice(ctx, deviceID)
	if err != nil {
		return err
	}

	defer d.Release(ctx)
	p, err := d.Provision(ctx, links)
	if err != nil {
		return err
	}
	defer p.Close(ctx)

	link, err := core.GetResourceLink(links, "/oic/sec/acl2")
	if err != nil {
		return err
	}

	setACL := acl.UpdateRequest{
		AccessControlList: []acl.AccessControl{
			acl.AccessControl{
				Permission: acl.AllPermissions,
				Subject: acl.Subject{
					Subject_Device: &acl.Subject_Device{
						DeviceID: c.hubConfiguration.GetId(),
					},
				},
				Resources: acl.AllResources,
			},
		},
	}

	err = p.UpdateResource(ctx, link, setACL, nil)
	if err != nil {
		return err
	}
	caCert := []byte(c.hubConfiguration.GetCertificateAuthorities())
	certs, err := security.ParseX509FromPEM(caCert)
	if err != nil {
		return err
	}
	return p.AddCertificateAuthority(ctx, c.hubConfiguration.GetId(), certs[0])
}

// OnboardDevice registers the device to the plgd cloud
func (c *Ocfclient) OnboardDevice(deviceID, authCode, authorizationProvider string) error {
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()
	cloudURL := c.hubConfiguration.GetCoapGateway()
	hubID := c.hubConfiguration.GetId()
	return c.client.OnboardDevice(ctx, deviceID, authorizationProvider, cloudURL, authCode, hubID)
}

// DisownDevice removes the current ownership
func (c *Ocfclient) DisownDevice(deviceID string) error {
	ctx, cancel := context.WithTimeout(context.Background(), 20*time.Second)
	defer cancel()
	return c.client.DisownDevice(ctx, deviceID)
}

const lets = `
-----BEGIN CERTIFICATE-----
MIIFazCCA1OgAwIBAgIRAIIQz7DSQONZRGPgu2OCiwAwDQYJKoZIhvcNAQELBQAw
TzELMAkGA1UEBhMCVVMxKTAnBgNVBAoTIEludGVybmV0IFNlY3VyaXR5IFJlc2Vh
cmNoIEdyb3VwMRUwEwYDVQQDEwxJU1JHIFJvb3QgWDEwHhcNMTUwNjA0MTEwNDM4
WhcNMzUwNjA0MTEwNDM4WjBPMQswCQYDVQQGEwJVUzEpMCcGA1UEChMgSW50ZXJu
ZXQgU2VjdXJpdHkgUmVzZWFyY2ggR3JvdXAxFTATBgNVBAMTDElTUkcgUm9vdCBY
MTCCAiIwDQYJKoZIhvcNAQEBBQADggIPADCCAgoCggIBAK3oJHP0FDfzm54rVygc
h77ct984kIxuPOZXoHj3dcKi/vVqbvYATyjb3miGbESTtrFj/RQSa78f0uoxmyF+
0TM8ukj13Xnfs7j/EvEhmkvBioZxaUpmZmyPfjxwv60pIgbz5MDmgK7iS4+3mX6U
A5/TR5d8mUgjU+g4rk8Kb4Mu0UlXjIB0ttov0DiNewNwIRt18jA8+o+u3dpjq+sW
T8KOEUt+zwvo/7V3LvSye0rgTBIlDHCNAymg4VMk7BPZ7hm/ELNKjD+Jo2FR3qyH
B5T0Y3HsLuJvW5iB4YlcNHlsdu87kGJ55tukmi8mxdAQ4Q7e2RCOFvu396j3x+UC
B5iPNgiV5+I3lg02dZ77DnKxHZu8A/lJBdiB3QW0KtZB6awBdpUKD9jf1b0SHzUv
KBds0pjBqAlkd25HN7rOrFleaJ1/ctaJxQZBKT5ZPt0m9STJEadao0xAH0ahmbWn
OlFuhjuefXKnEgV4We0+UXgVCwOPjdAvBbI+e0ocS3MFEvzG6uBQE3xDk3SzynTn
jh8BCNAw1FtxNrQHusEwMFxIt4I7mKZ9YIqioymCzLq9gwQbooMDQaHWBfEbwrbw
qHyGO0aoSCqI3Haadr8faqU9GY/rOPNk3sgrDQoo//fb4hVC1CLQJ13hef4Y53CI
rU7m2Ys6xt0nUW7/vGT1M0NPAgMBAAGjQjBAMA4GA1UdDwEB/wQEAwIBBjAPBgNV
HRMBAf8EBTADAQH/MB0GA1UdDgQWBBR5tFnme7bl5AFzgAiIyBpY9umbbjANBgkq
hkiG9w0BAQsFAAOCAgEAVR9YqbyyqFDQDLHYGmkgJykIrGF1XIpu+ILlaS/V9lZL
ubhzEFnTIZd+50xx+7LSYK05qAvqFyFWhfFQDlnrzuBZ6brJFe+GnY+EgPbk6ZGQ
3BebYhtF8GaV0nxvwuo77x/Py9auJ/GpsMiu/X1+mvoiBOv/2X/qkSsisRcOj/KK
NFtY2PwByVS5uCbMiogziUwthDyC3+6WVwW6LLv3xLfHTjuCvjHIInNzktHCgKQ5
ORAzI4JMPJ+GslWYHb4phowim57iaztXOoJwTdwJx4nLCgdNbOhdjsnvzqvHu7Ur
TkXWStAmzOVyyghqpZXjFaH3pO3JLF+l+/+sKAIuvtd7u+Nxe5AW0wdeRlN8NwdC
jNPElpzVmbUq4JUagEiuTDkHzsxHpFKVK7q4+63SM1N95R1NbdWhscdCb+ZAJzVc
oyi3B43njTOQ5yOf+1CceWxG1bQVs5ZufpsMljq4Ui0/1lvh+wjChP4kqKOJ2qxq
4RgqsahDYVvTH9w7jXbyLeiNdd8XM2w9U/t7y0Ff/9yi0GE44Za4rF2LN9d11TPA
mRGunUHBcnWEvgJBQl9nJEiU0Zsnvgc/ubhPgXRR4Xq37Z0j4r7g1SgEEzwxA57d
emyPxgcYxn/eR44/KJ4EBs+lVDR3veyJm+kXQ99b21/+jh5Xos1AnX5iItreGCc=
-----END CERTIFICATE-----`
