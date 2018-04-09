ExUnit.start()

# https://virviil.github.io/2016/10/26/Elixir-Testing-without-starting-supervision-tree.html

# when application is being compiled compiler emits warnings
# about not available mock module even though mock is defined
# right here using defmock, that is before starting application
#
# next when application is being started Mox raises error
# `no expectation defined for Neko.Shikimori.ClientMock.get_animes!/0`
# even though get_animes!/0 is stubbed right here using Mox.stub/3
#
# all in all I will fallback to plain mock modules for now
# (and setting required data with Store.set/2 functions)

# leave these line in case I want to try using Mox again
Application.ensure_all_started(:mox)
Application.ensure_all_started(:neko)
