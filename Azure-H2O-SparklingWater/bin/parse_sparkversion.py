import sys, json

for service in json.load(sys.stdin)['RepositoryVersions']['stack_services']:
 if service['name']=='SPARK2':
	print service['versions'][0].encode('ascii','ignore')[:3]

