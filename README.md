# Go-OCF Onboarding App


curl --request POST \
  --url 'https://auth.plgd.cloud/oauth/token' \
  --header 'content-type: application/x-www-form-urlencoded' \
  --data grant_type=authorization_code \
  --data 'client_id=cYN3p6lwNcNlOvvUhz55KvDZLQbJeDr5' \
  --data client_secret=qrccMDQjijrZDztK9-P151HgkDY1QqTh7WOhI3OT_0I0Mi53b-taxMC55iL4XYwa \
  --data code=WRzy519UaopbGCa5 \
  --data 'redirect_uri=https://portal.try.plgd.cloud'