// Preloaded into Happy (NODE_OPTIONS=--require) on machines behind an HTTP proxy.
// Happy's socket.io uses `ws`, which dials with tls.connect directly and ignores
// http(s)_proxy / NODE_USE_ENV_PROXY. Route those sockets through a proxy-aware
// agent (Node >= 24.5 `proxyEnv`, honors NO_PROXY).
'use strict';
const env = process.env;
if (env.https_proxy || env.HTTPS_PROXY || env.http_proxy || env.HTTP_PROXY) {
  const http = require('http');
  const https = require('https');
  let agents;
  try {
    agents = {
      http: new http.Agent({ proxyEnv: env, keepAlive: false }),
      https: new https.Agent({ proxyEnv: env, keepAlive: false }),
    };
  } catch {
    agents = null;
  }
  const wrap = (mod, agent) => {
    const orig = mod.request;
    mod.request = function (opts, ...rest) {
      if (opts && typeof opts === 'object' && !(opts instanceof URL) &&
          opts.createConnection && !opts.agent &&
          opts.headers && /websocket/i.test(String(opts.headers.Upgrade || opts.headers.upgrade || ''))) {
        opts = { ...opts, agent };
        delete opts.createConnection;
      }
      return orig.call(this, opts, ...rest);
    };
  };
  if (agents) {
    wrap(http, agents.http);
    wrap(https, agents.https);
  }
}
