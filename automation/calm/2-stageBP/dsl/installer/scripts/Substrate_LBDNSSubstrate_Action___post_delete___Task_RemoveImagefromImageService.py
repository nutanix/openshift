JWT = '@@{calm_jwt}@@'
ImageName ='RHCOS-@@{OPENSHIFT_SUBDOMAIN}@@'
# Get VM
api_url = 'https://localhost:9440/api/nutanix/v3/images/list'
headers = {'Content-Type': 'application/json',  'Accept':'application/json', 'Authorization': 'Bearer {}'.format(JWT)}
payload = {'kind':'image'}
r = urlreq(api_url, verb='POST', headers=headers,params=json.dumps(payload), verify=False)
if r.ok:
    resp = json.loads(r.content)

else:
    print("Post request failed", r.content)
    exit(1)

# Get Image UUID 
for entity in resp['entities']:
  if entity['status']['name'] == ImageName:
    ImageUUID = entity['metadata']['uuid']

api_url = 'https://localhost:9440/api/nutanix/v3/images/{}'.format(ImageUUID)

r = urlreq(api_url, verb='DELETE', headers=headers, verify=False)
if r.ok:
    resp = json.loads(r.content)
    taskUuid = resp['status']['execution_context']['task_uuid']

else:
    print("Post request failed", r.content)
    exit(1)
    
   
# Monitor task
state = ""
while state != "SUCCEEDED":
    api_url = 'https://localhost:9440/api/nutanix/v3/tasks/{}'.format(taskUuid)

    sleep(2)
    r = urlreq(api_url, verb='GET', headers=headers, verify=False)
    if r.ok:
        resp = json.loads(r.content)
        state = resp['status']
        if state == "FAILED":
            print("Task failed", resp['progress_message'])
            exit(1)

    else:
        print("Post request failed", r.content)
        exit(1)

print("Deleted {} from Image Service".format(ImageName))

