package Ocfclient

import (
	"context"
	"time"

	"github.com/plgd-dev/cloud/grpc-gateway/pb"
	grpcCloud "github.com/plgd-dev/cloud/pkg/net/grpc"
	"github.com/plgd-dev/kit/codec/json"
	"github.com/plgd-dev/kit/security"
	"github.com/plgd-dev/sdk/app"
	"github.com/plgd-dev/sdk/local"
	"github.com/plgd-dev/sdk/local/core"
	"github.com/plgd-dev/sdk/schema"
	"github.com/plgd-dev/sdk/schema/acl"
	"github.com/plgd-dev/sdk/schema/cloud"
	"google.golang.org/protobuf/encoding/protojson"
)

type (
	// Ocfclient for working with devices
	Ocfclient struct {
		localClient        *local.Client
		cloudConfiguration pb.CloudConfigurationResponse
	}
)

// Initialize creates and initializes new local client
func (c *Ocfclient) Initialize(accessToken, cloudConfiguration string) error {
	u := protojson.UnmarshalOptions{
		DiscardUnknown: true,
	}
	err := u.Unmarshal([]byte(cloudConfiguration), &c.cloudConfiguration)
	if err != nil {
		return err
	}
	appCallback, err := app.NewApp(&app.AppConfig{
		RootCA: lets + "\n" + c.cloudConfiguration.GetCloudCertificateAuthorities(),
	})
	localClient, err := local.NewClientFromConfig(&local.Config{
		DisablePeerTCPSignalMessageCSMs:   true,
		KeepAliveConnectionTimeoutSeconds: 10,
		ObserverPollingIntervalSeconds:    1,
		DeviceCacheExpirationSeconds:      3600,
		MaxMessageSize:                    512 * 1024,
		DeviceOwnershipBackend: &local.DeviceOwnershipBackendConfig{
			SigningServerAddress: c.cloudConfiguration.GetSigningServerAddress(),
			JWTClaimOwnerID:      c.cloudConfiguration.GetJwtOwnerClaim(),
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

	c.localClient = localClient
	return nil
}

func (c *Ocfclient) GetOwnerID() (string, error) {
	return c.localClient.CoreClient().GetSdkOwnerID()
}

// Discover devices in the local area
func (c *Ocfclient) Discover(timeoutSeconds int) (string, error) {
	ctx, cancel := context.WithTimeout(context.Background(), time.Duration(timeoutSeconds)*time.Second)
	defer cancel()
	res, err := c.localClient.GetDevices(ctx)
	if err != nil {
		return "", err
	}

	devices := []local.DeviceDetails{}
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

func getCloudConfiguration(ctx context.Context, device *core.Device, links schema.ResourceLinks) (out interface{}, _ error) {
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
	err := c.localClient.GetResource(ctx, deviceID, resourceHref, &data)
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
	return c.localClient.OwnDevice(ctx, deviceID, local.WithOTM(local.OTMType_JustWorks))
}

// SetAccessForCloud sets required ACL for the Cloud
func (c *Ocfclient) SetAccessForCloud(deviceID string) error {
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()
	d, links, err := c.localClient.GetRefDevice(ctx, deviceID)
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
						DeviceID: c.cloudConfiguration.GetCloudId(),
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
	caCert := []byte(c.cloudConfiguration.GetCloudCertificateAuthorities())
	certs, err := security.ParseX509FromPEM(caCert)
	if err != nil {
		return err
	}
	return p.AddCertificateAuthority(ctx, c.cloudConfiguration.GetCloudId(), certs[0])
}

// OnboardDevice registers the device to the plgd cloud
func (c *Ocfclient) OnboardDevice(deviceID, authCode string) error {
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()
	authorizationProvider := c.cloudConfiguration.GetCloudAuthorizationProvider()
	cloudURL := c.cloudConfiguration.GetCloudUrl()
	cloudID := c.cloudConfiguration.GetCloudId()
	return c.localClient.OnboardDevice(ctx, deviceID, authorizationProvider, cloudURL, authCode, cloudID)
}

// DisownDevice removes the current ownership
func (c *Ocfclient) DisownDevice(deviceID string) error {
	ctx, cancel := context.WithTimeout(context.Background(), 20*time.Second)
	defer cancel()
	return c.localClient.DisownDevice(ctx, deviceID)
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
