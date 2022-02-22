#region define variables
jwt     = '@@{calm_jwt}@@'
api_server = "localhost"
api_server_port = "9440"
api_server_endpoint = "/api/nutanix/v3/blueprints/list"
bp = "@@{OCP_BP}@@"

length = 100
url = "https://{}:{}{}".format(
    api_server,
    api_server_port,
    api_server_endpoint
)
#endregion

# region prepare api call
method = "POST"
headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer {}'.format(jwt)
}

# Compose the json payload
payload = {
  "kind": "blueprint",
  "offset": 0,
  "length": length
}
# endregion

#region make the api call
print("Making a {} API call to {}".format(method, url))
r = urlreq(
    url,
    verb=method,
    params=json.dumps(payload),
    headers=headers,
    verify=False
)
#endregion

#region process the results
if r.ok:
  for entity in json.loads(r.content)['entities']:
    #print entity
    if entity['status']['name'] == bp:
      blueprint_uuid=entity['status']['uuid']
      print 'blueprint_uuid='+blueprint_uuid
# If the call failed
else:
    # print the content of the response (which should have the error message)
    print("Request failed", json.dumps(
        json.loads(r.content),
        indent=4
    ))
    print("Headers: {}".format(headers))
    print("Payload: {}".format(payload))
    exit(1)
# endregion
