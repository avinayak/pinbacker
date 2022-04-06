defmodule Pinbacker.SessionHeaders do
  @moduledoc """
  A module for http headers for pintrest requests.
  takes version number as input
  """

  @user_agent "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/83.0.0.0 Safari/537.36"
  @versions [nil, "c643827", "4c8c36f"]

  def headers(:pin_sesssion) do
    # "Host", "www.pinterest.com",
    [
      {"User-Agent", @user_agent},
      {"Accept", "text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8"},
      {"Accept-Language", "en-US,en;q=0.5"},
      {"DNT", "1"},
      {"Upgrade-Insecure-Requests", "1"},
      {"Connection", "keep-alive"}
    ]
  end

  def headers(:img_session) do
    # "Host", "www.pinterest.com", #Image can be https://i.pinimg.com, so let it auto or else fail
    [
      {"User-Agent", @user_agent},
      {"Accept", "image/webp,*/*"},
      {"Accept-Language", "en-US,en;q=0.5"},
      {"Referer", "https://www.pinterest.com/"},
      {"Connection", "keep-alive"},
      {"Pragma", "no-cache"},
      {"Cache-Control", "no-cache"},
      {"TE", "Trailers"}
    ]
  end

  def headers(:video_session) do
    # 'https://v.pinimg.com/videos/mc/hls/8a/99/7d/8a997df97cab576795be2a4490457ea3.m3u8'
    [
      {"User-Agent", @user_agent},
      {"Accept", "*/*"},
      {"Accept-Language", "en-US,en;q=0.5"},
      {"Origin", "https://www.pinterest.com"},
      {"DNT", "1"},
      {"Referer", "https://www.pinterest.com/"},
      {"Connection", "keep-alive"},
      {"Pragma", "no-cache"},
      {"Cache-Control", "no-cache"}
    ]
  end

  def headers(version) do
    [
      {"User-Agent", @user_agent},
      {"Accept", "application/json, text/javascript, */*, q=0.01"},
      {"Accept-Language", "en-US,en;q=0.5"},
      {"Accept-Encoding", "gzip, deflate, br"},
      {"Referer", "https://www.pinterest.com/"},
      {"X-Requested-With", "XMLHttpRequest"},
      {"X-APP-VERSION", @versions[version]},
      {"X-Pinterest-AppState", "active"},
      {"X-Pinterest-PWS-Handler", "www/[username]/[slug]/[section},_slug].js"},
      {"DNT", "1"},
      {"Connection", "keep-alive"},
      {"Sec-Fetch-Dest", "empty"},
      {"Sec-Fetch-Mode", "cors"},
      {"Sec-Fetch-Site", "same-origin"},
      {"TE", "Trailers"}
    ]
  end
end
