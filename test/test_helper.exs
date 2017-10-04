ExUnit.start()

# shikimori client is used when starting application
# (for fetching animes from shikimori) but its mock
# is not defined yet at that moment - start application
# here manually after defining mock and stubbing its
# get_animes!/0 function to return dummy value

Application.ensure_all_started(:mox)

# mocks
Mox.defmock Neko.Shikimori.Client.Mock, for: Neko.Shikimori.Client

# set required data in tests by using Mox.stub/2 again
Neko.Shikimori.Client.Mock
|> Mox.stub(:get_animes!, fn -> [] end)

Application.ensure_all_started(:neko)
