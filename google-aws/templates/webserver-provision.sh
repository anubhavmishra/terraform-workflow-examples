#!/bin/bash

apt-get update
# Install webserver and its dependencies
apt-get install -y nginx vim

sudo tee /var/www/html/index.html > /dev/null <<"EOF"
<html>
<head>
  <title>Hello ${message}!!</title>
</head>
<body>
  <div style="padding: 100px;">
    <div style="width:40%; float:right; max-height:500px;">
      <img src="${image_url}" />
    </div>
    <div style="width:20%; float:left;">&nbsp;</div>
    <div style="width:40%; float:left; max-height:500px; padding-top:150px; font-size:24px; font-family:Helvetica,sans-serf;">
      Hello ${message}!! This is ${node_name}
    </div>
  </div>
</body>
</html>
EOF

systemctl restart nginx


