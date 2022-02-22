JWT = '@@{calm_jwt}@@'
vmUuid ='@@{id}@@'
# Get VM
api_url = 'https://localhost:9440/api/nutanix/v3/vms/{}'.format(vmUuid)
headers = {'Content-Type': 'application/json',  'Accept':'application/json', 'Authorization': 'Bearer {}'.format(JWT)}

r = urlreq(api_url, verb='GET', headers=headers, verify=False)
if r.ok:
    resp = json.loads(r.content)

else:
    print("Post request failed", r.content)
    exit(1)

# Power off VM
del resp['status']

resp['spec']['resources']['power_state'] = 'OFF'

payload = resp

r = urlreq(api_url, verb='PUT', params=json.dumps(payload), headers=headers, verify=False)
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

# Wait for VM to power off
api_url = 'https://localhost:9440/api/nutanix/v3/vms/{}'.format(vmUuid)
r = urlreq(api_url, verb='GET', headers=headers, verify=False)
if r.ok:
    resp = json.loads(r.content)
    power_state = resp['status']['resources']['power_state']

else:
    print("Post request failed", r.content)
    exit(1)

state = ""
while state != "OFF":
    api_url = 'https://localhost:9440/api/nutanix/v3/vms/{}'.format(vmUuid)

    sleep(2)
    r = urlreq(api_url, verb='GET', headers=headers, verify=False)
    if r.ok:
        resp = json.loads(r.content)
        state = resp['status']['resources']['power_state']
        if state == "FAILED":
            print("Task failed", resp['progress_message'])
            exit(1)

    else:
        print("Post request failed", r.content)
        exit(1)

# Remove ISO and Power on VM 
del resp['status']
# Remove ISO mount and disk size
disk_counter = 0
for disk in resp['spec']['resources']['disk_list']:
  del disk['disk_size_mib']
  if disk['device_properties']['device_type'] == "CDROM":
    del resp['spec']['resources']['disk_list'][disk_counter]
  disk_counter += 1


resp['spec']['resources']['power_state'] = 'ON'

api_url = 'https://localhost:9440/api/nutanix/v3/vms/{}'.format(vmUuid)
payload = resp

r = urlreq(api_url, verb='PUT', params=json.dumps(payload), headers=headers, verify=False)
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

print("Removed ISO from Bootstrap and booted into Disk")

# Wait until VM boots
sleep(60)
