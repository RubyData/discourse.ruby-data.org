# Prepare envchain

To manage credentials of AWS account, it is recommended to use [envchain](https://github.com/sorah/envchain).

```
$ envchain -s aws-ruby-data-discourse AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY
aws-ruby-data-discourse.AWS_ACCESS_KEY_ID: <input access key>
aws-ruby-data-discourse.AWS_SECRET_ACCESS_KEY: <input secret>
```

# Prepare terraform

```
$ envchain aws-ruby-data-discourse terraform init
```

# Select workspace

We have two workspaces: (1) `test`, and (2) `prod`. `test` workspace is for testing, and `prod` workspace is for production.

```
$ envchain aws-ruby-data-discourse terraform workspace show

$ envchain aws-ruby-data-discourse terraform workspace select test

$ envchain aws-ruby-data-discourse terraform workspace select prod
```

# Execute terraform

```
$ envchain aws-ruby-data-discourse terraform plan

$ envchain aws-ruby-data-discourse terraform apply
```
