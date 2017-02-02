from flask import request
from tempfile import mkstemp
from shutil import move
from os import remove, close
import fileinput,sys
from subprocess import call


from flask import Flask
app = Flask(__name__)

def modify_proxy(newIP):
    file_path = '/etc/nginx/conf.d/h2o.conf'
    h2o_docs = 'http://docs.h2o.ai/h2o/latest-stable/h2o-docs/azure.html#h2o-artificial-intelligence-for-hdinsight'  
    #Create temp file
    fh, abs_path = mkstemp()
    with open(abs_path,'w') as new_file:
        with open(file_path) as old_file:
            for line in old_file:
                if "proxy_pass" in line:
                    if newIP == "shutdown":
                        # Restore H2O on Azure Docs
                        new_line = "proxy_pass {0};".format(h2o_docs) + '}'
                                
                    else:
                        # Modify Nginx conf file
                        new_line = "proxy_pass {0};".format(newIP) + '}'
                else:
                    new_line = line
                print(new_line)
                new_file.write(new_line)
    close(fh)
    #Remove original file
    remove(file_path)
    #Move new file
    move(abs_path, file_path)
    
    
@app.route('/sw_configure', methods = ['POST'])
def api_message():
    if request.headers['Content-Type'] == 'text/plain':
        modify_proxy(request.data.decode("utf-8"))
        call('nginx -s reload')
        return request.data.decode("utf-8")
    return "415 Unsupported Media Type ;)"

if __name__ == '__main__':
    app.run()