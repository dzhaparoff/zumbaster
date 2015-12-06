do ->

  class MainCache
    constructor: (CacheFactory) ->
      self = this;
      self.playerCache = CacheFactory.get('playerCache')
      if !this.playerCache
        self.playerCache = CacheFactory 'playerCache',
          maxAge: 24*60*60*1000
          cacheFlushInterval: 7*24*60*60*1000
          deleteOnExpire: 'aggressive'
          storageMode: 'localStorage'


  angular
    .module "zumbaster"
    .service "mainCache", ['CacheFactory', MainCache]