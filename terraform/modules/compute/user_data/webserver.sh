#!/bin/bash
yum update -y
yum install -y httpd
systemctl start httpd
systemctl enable httpd

PUBLIC_IP=$(curl -s http://169.254.169.254/latest/meta-data/public-ipv4)

cat <<EOF > /var/www/html/index.html
<!DOCTYPE html>
<html>
<head>
    <title>ACS730 Group Project</title>
    <style>
        body {
            background-image: url('https://acs-final-project.s3.us-east-1.amazonaws.com/seneca.jpg');
            background-size: cover;
            background-repeat: no-repeat;
            color: white;
            text-shadow: 2px 2px 4px #000000;
            font-family: Arial, sans-serif;
        }
        .content {
            background-color: rgba(0, 0, 0, 0.6);
            padding: 20px;
            margin: 50px;
            border-radius: 10px;
        }
    </style>
</head>
<body>
    <div class="content">
        <h1>Hello from ACS730 Group Project</h1>
        <p>Environment: ${environment}</p>
        <p>Public IP: $PUBLIC_IP</p>
        <p>Instance Type: ${instance_type}</p>
    </div>
</body>
</html>
EOF

chmod 644 /var/www/html/index.html
systemctl restart httpd
