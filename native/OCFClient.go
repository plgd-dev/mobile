package ocfclient

import (
	"context"
	"encoding/json"
	"fmt"
	"time"

	kitGrpc "github.com/go-ocf/kit/net/grpc"
	"github.com/go-ocf/kit/strings"
	"github.com/go-ocf/sdk/app"
	"github.com/go-ocf/sdk/local"
	"github.com/go-ocf/sdk/local/core"
	"github.com/go-ocf/sdk/schema"
	"github.com/go-ocf/sdk/schema/cloud"
)

type (
	// OCFClient for working with devices
	OCFClient struct {
		localClient *local.Client
		// add fields here
	}
)

// Initialize creates and initializes new local client
func (c *OCFClient) Initialize() error {
	appCallback, err := app.NewApp(&app.AppConfig{
		RootCA: lets,
		Manufacturer: &app.ManufacturerCerts{
			CA:      mfgCa,
			Cert:    mfgCrt,
			CertKey: mfgCrtKey,
		},
	})
	localClient, err := local.NewClientFromConfig(&local.Config{
		DisablePeerTCPSignalMessageCSMs:   true,
		KeepAliveConnectionTimeoutSeconds: 1,
		ObserverPollingIntervalSeconds:    1,
		DeviceOwnershipBackend: &local.DeviceOwnershipBackendConfig{
			AccessTokenURL:       "https://portal.try.plgd.cloud/api/authz/token",
			AuthCodeURL:          "https://portal.try.plgd.cloud/api/authz/code",
			JWTClaimOwnerID:      "sub",
			SigningServerAddress: "try.plgd.cloud:443",
		},
	}, appCallback, func(err error) {
		fmt.Println(err)
	})
	if err != nil {
		return err
	}

	ctx, cancel := context.WithTimeout(context.Background(), 4*time.Second)
	defer cancel()
	ctx = kitGrpc.CtxWithToken(ctx, "eyJhbGciOiJSUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IlFrWTRNekZHTVRkRk16TXlOME5HUWpFeU9VRkZNekU1UTBaRU1VWXpRVVF4TmtORU5UbEVNZyJ9.eyJpc3MiOiJodHRwczovL2F1dGgucGxnZC5jbG91ZC8iLCJzdWIiOiJnb29nbGUtb2F1dGgyfDExNDczNDUzNDcxMjIzMzUwNDE3NSIsImF1ZCI6WyJodHRwczovL3RyeS5wbGdkLmNsb3VkIiwiaHR0cHM6Ly9vY2ZjbG91ZC5ldS5hdXRoMC5jb20vdXNlcmluZm8iXSwiaWF0IjoxNTg2NjM5NzE2LCJleHAiOjE1ODY2NDY5MTYsImF6cCI6ImNZTjNwNmx3TmNObE92dlVoejU1S3ZEWkxRYkplRHI1Iiwic2NvcGUiOiJvcGVuaWQifQ.TnqZzKp06zlsteNK4OrOYDnWPeO01E8hlVtPw2ofI6395taWVw9eBCwBWiiKY0bMy5aJyl1EZKuo2n6mVn7ckMxLeidF_0hGGmvB3nkzrMK0xmUqg4evlec7vghLknfU3w7jYy2SSZsnyZy9S6sXsc05glhov_60kHvIcbMaBWLBZHW026aWGDOxDZYPv__LDrzGvbOVb5tH7iRh14-U7x43Ys-NP5Y8tZMUv5Dp7mJ89QFHG4SlszZcWjtve-JEiBzcjuiT-NjsQ1CuIuYc3h35a3Xuihy-MHCWgIgqYIDGCqk6FoXfK7HtxuTEV8AGpWwpDyr_M0HcFBTF_kQ4ag")
	err = localClient.Initialization(ctx)
	if err != nil {
		return err
	}

	c.localClient = localClient
	return nil
}

// Discover devices in the local area
func (c *OCFClient) Discover() (string, error) {
	ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
	defer cancel()
	res, err := c.localClient.GetDevices(ctx, local.WithGetDetails(getCloudConfiguration))
	if err != nil {
		return "", err
	}

	defer func() {
		_ = c.localClient.Close(context.Background())
	}()

	devices := []local.DeviceDetails{}
	for _, device := range res {
		devices = append(devices, device)
	}

	devicesJSON, err := json.Marshal(devices)
	if err != nil {
		return "", err
	}
	return string(devicesJSON), nil
}

func getCloudConfiguration(ctx context.Context, device *core.Device, links schema.ResourceLinks) (out interface{}, _ error) {
	var link schema.ResourceLink
	for _, l := range links {
		if strings.SliceContains(l.ResourceTypes, cloud.ConfigurationResourceType) {
			link = l
			break
		}
	}

	var cloudConfiguration cloud.Configuration
	err := device.GetResource(ctx, link, &cloudConfiguration)
	if err != nil {
		fmt.Println(err)
		return nil, nil
	}
	return &cloudConfiguration, nil
}

// OwnDevice transfers the ownersip of the device to user represented by the token
func (c *OCFClient) OwnDevice(deviceID, token string) error {
	ctx, cancel := context.WithTimeout(context.Background(), 10*time.Second)
	defer cancel()
	ctx = kitGrpc.CtxWithToken(ctx, token)
	err := c.localClient.OwnDevice(ctx, deviceID)
	if err != nil {
		fmt.Println(err)
		return err
	}
	return nil
}

// OnboardDevice registers the device to the Go-OCF Cloud
func (c *OCFClient) OnboardDevice(deviceID, authorizationProvider, cloudURL, authCode, cloudID string) error {
	ctx, cancel := context.WithTimeout(context.Background(), 20*time.Second)
	defer cancel()
	err := c.localClient.OnboardDevice(ctx, deviceID, authorizationProvider, cloudURL, authCode, cloudID)
	if err != nil {
		fmt.Println(err)
		return err
	}
	return nil
}

// OffboardDevice deregisters the device from the cloud where it's connected to
func (c *OCFClient) OffboardDevice(deviceID string) error {
	ctx, cancel := context.WithTimeout(context.Background(), 20*time.Second)
	defer cancel()
	err := c.localClient.OffboardDevice(ctx, deviceID)
	if err != nil {
		fmt.Println(err)
		return err
	}
	return nil
}

// DisownDevice removes the current ownership
func (c *OCFClient) DisownDevice(deviceID string) error {
	ctx, cancel := context.WithTimeout(context.Background(), 20*time.Second)
	defer cancel()
	err := c.localClient.DisownDevice(ctx, deviceID)
	if err != nil {
		fmt.Println(err)
		return err
	}
	return nil
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

const rootCa = `
-----BEGIN CERTIFICATE-----
MIIBhDCCASmgAwIBAgIQdAMxveYP9Nb48xe9kRm3ajAKBggqhkjOPQQDAjAxMS8w
LQYDVQQDEyZPQ0YgQ2xvdWQgUHJpdmF0ZSBDZXJ0aWZpY2F0ZXMgUm9vdCBDQTAe
Fw0xOTExMDYxMjAzNTJaFw0yOTExMDMxMjAzNTJaMDExLzAtBgNVBAMTJk9DRiBD
bG91ZCBQcml2YXRlIENlcnRpZmljYXRlcyBSb290IENBMFkwEwYHKoZIzj0CAQYI
KoZIzj0DAQcDQgAEaNJi86t5QlZiLcJ7uRMNlcwIpmFiJf9MOqyz2GGnGVBypU6H
lwZHY2/l5juO/O4EH2s9h3HfcR+nUG2/tFzFEaMjMCEwDgYDVR0PAQH/BAQDAgEG
MA8GA1UdEwEB/wQFMAMBAf8wCgYIKoZIzj0EAwIDSQAwRgIhAM7gFe39UJPIjIDE
KrtyPSIGAk0OAO8txhow1BAGV486AiEAqszg1fTfOHdE/pfs8/9ZP5gEVVkexRHZ
JCYVaa2Spbg=
-----END CERTIFICATE-----`

const mfgCa = `
-----BEGIN CERTIFICATE-----
MIIBaTCCAQ+gAwIBAgIQR33gIB75I7Vi/QnMnmiWvzAKBggqhkjOPQQDAjATMREw
DwYDVQQKEwhUZXN0IE9SRzAeFw0xOTA1MDIyMDA1MTVaFw0yOTAzMTAyMDA1MTVa
MBMxETAPBgNVBAoTCFRlc3QgT1JHMFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAE
xbwMaS8jcuibSYJkCmuVHfeV3xfYVyUq8Iroz7YlXaTayspW3K4hVdwIsy/5U+3U
vM/vdK5wn2+NrWy45vFAJqNFMEMwDgYDVR0PAQH/BAQDAgEGMBMGA1UdJQQMMAoG
CCsGAQUFBwMBMA8GA1UdEwEB/wQFMAMBAf8wCwYDVR0RBAQwAoIAMAoGCCqGSM49
BAMCA0gAMEUCIBWkxuHKgLSp6OXDJoztPP7/P5VBZiwLbfjTCVRxBvwWAiEAnzNu
6gKPwtKmY0pBxwCo3NNmzNpA6KrEOXE56PkiQYQ=
-----END CERTIFICATE-----`

const mfgCrt = `
-----BEGIN CERTIFICATE-----
MIIB9zCCAZygAwIBAgIRAOwIWPAt19w7DswoszkVIEIwCgYIKoZIzj0EAwIwEzER
MA8GA1UEChMIVGVzdCBPUkcwHhcNMTkwNTAyMjAwNjQ4WhcNMjkwMzEwMjAwNjQ4
WjBHMREwDwYDVQQKEwhUZXN0IE9SRzEyMDAGA1UEAxMpdXVpZDpiNWEyYTQyZS1i
Mjg1LTQyZjEtYTM2Yi0wMzRjOGZjOGVmZDUwWTATBgcqhkjOPQIBBggqhkjOPQMB
BwNCAAQS4eiM0HNPROaiAknAOW08mpCKDQmpMUkywdcNKoJv1qnEedBhWne7Z0jq
zSYQbyqyIVGujnI3K7C63NRbQOXQo4GcMIGZMA4GA1UdDwEB/wQEAwIDiDAzBgNV
HSUELDAqBggrBgEFBQcDAQYIKwYBBQUHAwIGCCsGAQUFBwMBBgorBgEEAYLefAEG
MAwGA1UdEwEB/wQCMAAwRAYDVR0RBD0wO4IJbG9jYWxob3N0hwQAAAAAhwR/AAAB
hxAAAAAAAAAAAAAAAAAAAAAAhxAAAAAAAAAAAAAAAAAAAAABMAoGCCqGSM49BAMC
A0kAMEYCIQDuhl6zj6gl2YZbBzh7Th0uu5izdISuU/ESG+vHrEp7xwIhANCA7tSt
aBlce+W76mTIhwMFXQfyF3awWIGjOcfTV8pU
-----END CERTIFICATE-----`

const mfgCrtKey = `
-----BEGIN EC PRIVATE KEY-----
MHcCAQEEIMPeADszZajrkEy4YvACwcbR0pSdlKG+m8ALJ6lj/ykdoAoGCCqGSM49
AwEHoUQDQgAEEuHojNBzT0TmogJJwDltPJqQig0JqTFJMsHXDSqCb9apxHnQYVp3
u2dI6s0mEG8qsiFRro5yNyuwutzUW0Dl0A==
-----END EC PRIVATE KEY-----`
