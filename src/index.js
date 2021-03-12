import './main.css';
import { Elm } from './Main.elm';

const startingAccessToken = localStorage.getItem('accessToken');

const app = Elm.Main.init({
  node: document.getElementById('root'),
  flags: { maybeAccessToken: startingAccessToken }
});

app.ports.saveAccessToken.subscribe( function(accessToken) {
    localStorage.setItem('accessToken', accessToken);
});

app.ports.removeAccessToken.subscribe( function(accessToken) {
    localStorage.removeItem('accessToken', accessToken);
});
