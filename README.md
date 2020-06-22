# flickr
iOS application to view and comment on Flickr photos

## How to
### Adding Keys to Build Directory
* Create a `Build` directory in the app source directory
* Apply for a [Flickr API Key](https://www.flickr.com/services/apps/create/apply)
* In the `Build` directory create a `env-vars.sh` file
* Add your app keys to the `env-vars.sh` file
```
export FLICKR_API_KEY={FLICKR_API_KEY}
export FLICKR_API_SECRET={FLICKR_API_SECRET}
```
