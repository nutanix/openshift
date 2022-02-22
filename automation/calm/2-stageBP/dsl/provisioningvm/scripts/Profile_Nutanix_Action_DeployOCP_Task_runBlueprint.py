 #region define variables
jwt     = '@@{calm_jwt}@@'
api_server = "localhost"
api_server_port = "9440"
api_server_endpoint = "/api/nutanix/v3/blueprints/{}/runtime_editables".format("@@{blueprint_uuid}@@")

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
    resp_json = json.loads(r.content)
    #variable_list = json.dumps(json_resp['resources'][0]['runtime_editables']['variable_list'])
# If the call failed
else:
    # print the content of the response (which should have the error message)
    print("Request failed")
    exit(1)
# endregion


#### RUN BP

#region define variables
api_server_endpoint = "/api/nutanix/v3/blueprints/{}/simple_launch".format("@@{blueprint_uuid}@@")

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
  "spec": {
    "app_name": "OpenShift @@{OCP_SUBDOMAIN}@@",
    "app_description": "Automated OCP Tenant",
    "app_profile_reference": {
      "kind": "app_profile",
      "name": ""
    },
    "runtime_editables": {
      "variable_list":[],
      "credential_list":[]
    }
  }
}

if (@@{COMPUTE_NODES}@@==0):
	payload['spec']['app_profile_reference']['name']='ControlPlaneOnly'
else:
	payload['spec']['app_profile_reference']['name']='ControlPlaneCompute'


payload['spec']['runtime_editables']['variable_list']=resp_json['resources'][0]['runtime_editables']['variable_list']
payload['spec']['runtime_editables']['credential_list']=resp_json['resources'][0]['runtime_editables']['credential_list']

payload['spec']['runtime_editables']['variable_list'][0]['value']['value']="@@{BASE_DOMAIN}@@"
payload['spec']['runtime_editables']['variable_list'][1]['value']['value']="@@{OCP_SUBDOMAIN}@@"
payload['spec']['runtime_editables']['variable_list'][2]['value']['value']="@@{address}@@"
payload['spec']['runtime_editables']['variable_list'][3]['value']['value']="@@{OCP_MACHINE_NETWORK}@@"
payload['spec']['runtime_editables']['variable_list'][4]['value']['value']='@@{KUBECONFIG}@@'
payload['spec']['runtime_editables']['variable_list'][5]['value']['value']='@@{KUBEADMIN}@@'
payload['spec']['runtime_editables']['variable_list'][6]['value']['value']='@@{platform.status.resources.nic_list[0].subnet_reference.uuid}@@'
payload['spec']['runtime_editables']['variable_list'][7]['value']['value']='@@{COMPUTE_NODES}@@'
payload['spec']['runtime_editables']['variable_list'][8]['value']['value']='@@{LBDNS_IP}@@'

payload['spec']['runtime_editables']['credential_list'][0]['value']['secret']['attrs']['is_secret_modified']=True

ol_cred ="""@@{CRED.secret}@@"""
payload['spec']['runtime_editables']['credential_list'][0]['value']['secret']['value']=ol_cred

print payload
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
    resp_json = json.loads(r.content)
    print "launch_uuid={}".format(resp_json["status"]["request_id"])
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