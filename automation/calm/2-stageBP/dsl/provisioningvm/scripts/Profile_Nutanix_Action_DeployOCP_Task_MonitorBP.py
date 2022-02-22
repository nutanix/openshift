 #region define variables
jwt     = '@@{calm_jwt}@@'
api_server = "localhost"
api_server_port = "9440"
api_server_endpoint = "/api/nutanix/v3/blueprints/{}/pending_launches/{}".format("@@{blueprint_uuid}@@","@@{launch_uuid}@@")

length = 100
url = "https://{}:{}{}".format(
    api_server,
    api_server_port,
    api_server_endpoint
)
#endregion

# region prepare api call
method = "GET"
headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'Authorization': 'Bearer {}'.format(jwt)
}


#region make the api call
print("Making a {} API call to {}".format(method, url))
r = urlreq(
    url,
    verb=method,
    headers=headers,
    verify=False
)
#endregion

#region process the results
if r.ok:
    print r.content
    #variable_list = json.dumps(json_resp['resources'][0]['runtime_editables']['variable_list'])
# If the call failed
else:
    # print the content of the response (which should have the error message)
    print("Request failed")
    exit(1)
# endregion
