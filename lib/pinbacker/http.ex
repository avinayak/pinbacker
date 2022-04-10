defmodule Pinbacker.HTTP do
  @moduledoc """
  A module for http headers for pintrest requests.
  takes version number as input
  """

  require Logger

  @user_agent "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/83.0.0.0 Safari/537.36"
  @versions [nil, "c643827", "4c8c36f"]

  defp headers(:pin) do
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

  defp headers(:img) do
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

  defp headers(:video) do
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

  defp headers(version) do
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

  def get(header_version, url, query \\ %{}) do
    case HTTPoison.get(url, headers(header_version), follow_redirect: true, params: query) do
      {:ok, %HTTPoison.Response{status_code: 200, body: body}} ->
        {:ok, body}

      {:error, error} ->
        {:error, error}
    end
  end

  def download!(header_version, file_url, filename) do
    if File.exists?(filename) do
      # File.open!(filename, [:append])
      IO.write("File Exists #{filename}")
    else
      File.touch!(filename)
      file = File.open!(filename, [:append])
      Logger.info("Downloading to #{filename}")

      %HTTPoison.AsyncResponse{id: ref} =
        HTTPoison.get!(file_url, headers(header_version), stream_to: self())

      append_loop(ref, file)
    end
  end

  defp append_loop(ref, file) do
    receive do
      %HTTPoison.AsyncChunk{chunk: chunk, id: ^ref} ->
        IO.binwrite(file, chunk)
        append_loop(ref, file)

      %HTTPoison.AsyncEnd{id: ^ref} ->
        {:ok, File.close(file)}

      _ ->
        append_loop(ref, file)
    end
  end
end
