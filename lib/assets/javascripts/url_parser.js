// è più veloce e potente di document.createElement('a'); a.href = url
// http://jsperf.com/url-parsing/5
// Usage: parsed = UrlParser.get(url): url.href ...
UrlParser = {
  regx: /^(((([^:\/#\?]+:)?(?:(\/\/)((?:(([^:@\/#\?]+)(?:\:([^:@\/#\?]+))?)@)?(([^:\/#\?\]\[]+|\[[^\/\]@#?]+\])(?:\:([0-9]+))?))?)?)?((\/?(?:[^\/\?#]+\/+)*)([^\?#]*)))?(\?[^#]+)?)(#.*)?/,
  parse: function(url) {
    if(typeof url !== 'string') {
      return null;
    }
    var matches = this.regx.exec(url);
    var search = matches[16];
    var searchObj = {};
    if(search && search !== '' && search !== '?') {
      var searches = search.replace(/^\?/, '').split('&');
      for(var i = 0; i < searches.length; i++) {
        var search_and_result = searches[i].split('=');
        searchObj[search_and_result[0]] = search_and_result[1];
      }
    }
    return {
      href: matches[0],
      withoutHash: matches[1],
      url: matches[2],
      origin: matches[3],
      protocol: matches[4],
      protocolseparator: matches[5],
      credhost: matches[6],
      cred: matches[7],
      user: matches[8],
      pass: matches[9],
      host: matches[10],
      hostname: matches[11],
      port: matches[12],
      pathname: matches[13],
      segment1: matches[14],
      segment2: matches[15],
      search: search,
      searchObj: searchObj,
      hash: matches[17]
    };
  }
};
