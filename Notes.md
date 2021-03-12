# Notes on implementing Auto0

Based on the example app `https://github.com/zstatmanweil/goodtimes`.


## index.html

From 01-login `index.html`

Notice this line
````
    <script src="https://cdn.auth0.com/js/auth0-spa-js/1.13/auth0-spa-js.production.js"></script>
````

here

````
    <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/3.3.1/jquery.min.js"></script>
    <script src="https://stackpath.bootstrapcdn.com/bootstrap/4.3.1/js/bootstrap.bundle.min.js"></script>
    <script src="https://cdn.auth0.com/js/auth0-spa-js/1.13/auth0-spa-js.production.js"></script>
    <script src="//cdnjs.cloudflare.com/ajax/libs/highlight.js/9.15.6/highlight.min.js"></script>
    <script src="js/ui.js"></script>
    <script src="js/app.js"></script>
  </body>
</html>
````

From GoodTimes

````
<!doctype html>
<html>
    <head>
        <title>Good Times</title>
        <link rel="stylesheet" href="styles/index.scss" />
    </head>
    <body>
        <main id="mount"></main>

        <script src="https://cdn.auth0.com/js/auth0-spa-js/1.9/auth0-spa-js.production.js"></script>
        <script src="./index.js"></script>
    </body>
</html>
````


## Elm Packages

This is the `elm.json` file from GoodTimes. This is a very good clue to where to look for useful tools.
Especially we notice: `kkpoon/elm-auth0`


````
{
    "type": "application",
    "source-directories": [
        "src"
    ],
    "elm-version": "0.19.1",
    "dependencies": {
        "direct": {
            "elm/browser": "1.0.2",
            "elm/core": "1.0.5",
            "elm/html": "1.0.0",
            "elm/http": "2.0.0",
            "elm/json": "1.1.3",
            "elm/url": "1.0.0",
            "elm-community/json-extra": "4.3.0",
            "elm-community/list-extra": "8.2.4",
            "elm-community/maybe-extra": "5.2.0",
            "kkpoon/elm-auth0": "4.0.0",
            "krisajenkins/remotedata": "6.0.1"
        },
        "indirect": {
            "elm/bytes": "1.0.8",
            "elm/file": "1.0.5",
            "elm/parser": "1.1.0",
            "elm/time": "1.0.0",
            "elm/virtual-dom": "1.0.2",
            "rtfeldman/elm-iso8601-date-strings": "1.1.3"
        }
    },
    "test-dependencies": {
        "direct": {},
        "indirect": {}
    }
}
````


## Domain and Client ID

Find the `/static/auth_config.json` file and replace it with your credentials.

````
{
  "domain": "dev-ws5cy8ag.eu.auth0.com",
  "clientId": "wyX6Vks88k9hdXfjv5zpkpy5KSPyi9wT"
}
````


## Cookies vs Local Storage

Find the `index.js` file.

elm-rails-todo uses Cookies

````
import Cookies from 'js-cookie';

document.addEventListener('DOMContentLoaded', function (event) {
  const app = Elm.Main.init({
      node: document.getElementById('root'),
      flags: Cookies.get('appAuthToken')
  })

  app.ports.storeAuthInfo.subscribe(function(auth) {
    Cookies.set('appAuthToken', auth, { expires: 7 });
  });

  app.ports.clearAuthInfo.subscribe(function(data) {
    Cookies.remove('appAuthToken');
  });
})

````

Jack Franklin uses Local Storage

````
import './main.css';
import { Elm } from './Main.elm';

const app = Elm.Main.init({
  node: document.getElementById('root'),
  flags: {
    storedToken: localStorage.getItem('__DISTINCTLY_AVERAGE__'),
  },
});

app.ports.sendTokenToStorage.subscribe(token => {
  console.log('GOT TOKEN ', token)
  localStorage.setItem('__DISTINCTLY_AVERAGE__', 'This is supposed to be the token')
});
````

Goodtimes uses Local Storage (looks best)

````
import { Elm } from './Main.elm';

const startingAccessToken = localStorage.getItem('accessToken')

const app = Elm.Main.init({
  node: document.getElementById('mount'),
  flags: { maybeAccessToken: startingAccessToken }
})

app.ports.saveAccessToken.subscribe( function(accessToken) {
    localStorage.setItem('accessToken', accessToken);
});

app.ports.removeAccessToken.subscribe( function(accessToken) {
    localStorage.removeItem('accessToken', accessToken);
});

````



