# Concept #

Escape provides a RESTful interface for both the setting and getting of environment configuration.


`GET` requests will retrieve configuration, whereas `PUT` requests will set it.

# URL scheme #

This is most easily demonstrated by constructing an example URL.
| **URL** | **Value returned** |
|:--------|:-------------------|
| `http://escape/`| User interface. No API available here. |
| `http://escape/environments/` | A list of all the available environments. |
| `http://escape/environments/production/` | A list of all the applications in the "production" environment. |
| `http://escape/environments/production/mywebapp` | All keys and values for the "mywebapp" application in the "production" environment. |
| `http://escape/environments/production/mywebapp/thiskey` | The value of "thiskey" for the "mywebapp" application in the "production" environment. |

# Example Usage #

A common use is for an application's install script to get a list of target machines for installation. If you had an installation script in bash, it might contain a section like this:

```
MYENV = $1
export TARGET_HOSTS=`wget -q http://escape/environments/$MYENV/myapplication/target_hosts --output-document=-`
for host in $TARGET_HOSTS
do
run_installation_on $host
done
```

Note that the only variable passed to the script is the target environment. This is good practice - we should be using the same install script in all of our environments. That way, we are testing our deployment process during development and we de-risk our deployment to production.