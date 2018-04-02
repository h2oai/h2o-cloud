import sys, json

try:
	for host in json.load(sys.stdin)['items']:	
		dns = host["Hosts"]["host_name"].split('-')[0].encode('ascii','ignore')
		if 'ed' in dns:
		    print host["Hosts"]["host_name"]
		    break
except ValueError:
		print("Unable to Find Edgenode DNS")
