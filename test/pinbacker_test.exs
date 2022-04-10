defmodule PinbackerTest do
  use ExUnit.Case

  alias Pinbacker.Utils

  @download_base "test/downloads"

  doctest Pinbacker

  test "directory tree" do
    assert Utils.directory_tree("root/", ["a", "b", "c"]) == "root/a/b/c/"
  end

  test "section download" do
    File.rm_rf!(@download_base)
    destination = "#{@download_base}/section"
    Pinbacker.fetch("https://www.pinterest.jp/atulsvinayak/analog/outdoor/", destination)

    assert Utils.list_all_files(destination) == [
             "test/downloads/section/atulsvinayak/analog/outdoor/d119db17471e4eff69fdab0af12311ff.jpg",
             "test/downloads/section/atulsvinayak/analog/outdoor/bb245e500788afe263f0c2d6ff0665fa.webp",
             "test/downloads/section/atulsvinayak/analog/outdoor/77ecfdc0bd31b791e8e6278e2be14d9e.jpg"
           ]

    File.rm_rf!(@download_base)
  end

  test "board download" do
    File.rm_rf!(@download_base)
    destination = "#{@download_base}/board_1"
    Pinbacker.fetch("https://www.pinterest.jp/atulsvinayak/portraits/", destination)

    assert Utils.list_all_files(destination) == [
             "test/downloads/board_1/atulsvinayak/portraits/c96a47db6554cb36a5d1194d0213b806.jpg",
             "test/downloads/board_1/atulsvinayak/portraits/6e457c575857869e087a8498fda6fe0d.jpg",
             "test/downloads/board_1/atulsvinayak/portraits/80fc4d1ff96f15295d79553fb102f65d.png",
             "test/downloads/board_1/atulsvinayak/portraits/8780704dfe2d26f4897997ea91dba4d1.jpg",
             "test/downloads/board_1/atulsvinayak/portraits/34995c5ea9a729a4695d65edfca7472b.jpg",
             "test/downloads/board_1/atulsvinayak/portraits/71b313f245396ce2726064274c199e2e.jpg",
             "test/downloads/board_1/atulsvinayak/portraits/d23a12cefb0e23ae1be4b0f5d9880222.jpg",
             "test/downloads/board_1/atulsvinayak/portraits/e9ff01390cb99a04192f6be9d4418926.jpg"
           ]

    File.rm_rf!(@download_base)
  end

  @tag timeout: :infinity
  test "board with section download" do
    File.rm_rf!(@download_base)
    destination = "#{@download_base}/board_2"
    Pinbacker.fetch("https://www.pinterest.jp/atulsvinayak/analog", destination)

    assert Utils.list_all_files(destination) == [
             "test/downloads/board_2/atulsvinayak/analog/e9d9bbd0b6470acf543bae48afbfd693.jpg",
             "test/downloads/board_2/atulsvinayak/analog/3ecd39e41de5885ac6ae2572819d6c45.jpg",
             "test/downloads/board_2/atulsvinayak/analog/53612d4a297094adbae601dadad7a61f.jpg",
             "test/downloads/board_2/atulsvinayak/analog/1d5678c38f8ca24fe0c88c7bb5d225f9.jpg",
             "test/downloads/board_2/atulsvinayak/analog/c699227b5b89f259b184dac4df8c20d7.jpg",
             "test/downloads/board_2/atulsvinayak/analog/66da7636af01ee0bc507f68c9e23e400.png",
             "test/downloads/board_2/atulsvinayak/analog/6afca48aca3fd976495e1c14629ad560.png",
             "test/downloads/board_2/atulsvinayak/analog/8287607906ef4c9ab4b360d20b67bb09.jpg",
             "test/downloads/board_2/atulsvinayak/analog/24861105f0835aebfa90a396613137d0.jpg",
             "test/downloads/board_2/atulsvinayak/analog/outdoor/d119db17471e4eff69fdab0af12311ff.jpg",
             "test/downloads/board_2/atulsvinayak/analog/outdoor/bb245e500788afe263f0c2d6ff0665fa.webp",
             "test/downloads/board_2/atulsvinayak/analog/outdoor/77ecfdc0bd31b791e8e6278e2be14d9e.jpg",
             "test/downloads/board_2/atulsvinayak/analog/9482e9b59319d1ea6abb023fbc0c41b0.jpg",
             "test/downloads/board_2/atulsvinayak/analog/fa48ac8a9a8007c9cfa6262ae2afc673.jpg",
             "test/downloads/board_2/atulsvinayak/analog/ee3fe16060aedab7a6b41440115fa333.jpg",
             "test/downloads/board_2/atulsvinayak/analog/2be5535ea5c673c119b240d31279a333.jpg",
             "test/downloads/board_2/atulsvinayak/analog/f9b2ff0973d7b67f1da6a9c6ff9a90ce.jpg",
             "test/downloads/board_2/atulsvinayak/analog/2d6db15bafe12c4cb149b668ef9eceb7.jpg",
             "test/downloads/board_2/atulsvinayak/analog/fff1aff98ce46d9884a9282ed180b330.jpg",
             "test/downloads/board_2/atulsvinayak/analog/89c873470e85114fe95083176f8113b7.jpg",
             "test/downloads/board_2/atulsvinayak/analog/f712e1a35058d4ec2c28d0e8bc465907.jpg",
             "test/downloads/board_2/atulsvinayak/analog/df4ba2cb609d73b014435c1535044860.jpg",
             "test/downloads/board_2/atulsvinayak/analog/6378cfd740cfbabe02171ae6131c466f.jpg",
             "test/downloads/board_2/atulsvinayak/analog/eca727875b855c6ae5aec49f41e8ad0f.jpg",
             "test/downloads/board_2/atulsvinayak/analog/5f3f2fd7b75ec83295f74ef2f5cf1d29.jpg",
             "test/downloads/board_2/atulsvinayak/analog/de6de741a21d4fd9f629134f4c4ab996.png",
             "test/downloads/board_2/atulsvinayak/analog/a7b4fa00460d160ace383d6bbe214c15.jpg",
             "test/downloads/board_2/atulsvinayak/analog/ebc8966acdcd9998b7e748e03952f1da.jpg",
             "test/downloads/board_2/atulsvinayak/analog/d6370b14649b78e1a51f43a182a300bc.jpg"
           ]

    File.rm_rf!(@download_base)
  end

  @tag timeout: :infinity
  test "user download" do
    File.rm_rf!(@download_base)
    destination = "#{@download_base}/user"
    Pinbacker.fetch("https://www.pinterest.jp/atulsvinayak/", destination)

    assert Utils.list_all_files(destination) == [
             "test/downloads/user/atulsvinayak/portraits/c96a47db6554cb36a5d1194d0213b806.jpg",
             "test/downloads/user/atulsvinayak/portraits/6e457c575857869e087a8498fda6fe0d.jpg",
             "test/downloads/user/atulsvinayak/portraits/80fc4d1ff96f15295d79553fb102f65d.png",
             "test/downloads/user/atulsvinayak/portraits/8780704dfe2d26f4897997ea91dba4d1.jpg",
             "test/downloads/user/atulsvinayak/portraits/34995c5ea9a729a4695d65edfca7472b.jpg",
             "test/downloads/user/atulsvinayak/portraits/71b313f245396ce2726064274c199e2e.jpg",
             "test/downloads/user/atulsvinayak/portraits/d23a12cefb0e23ae1be4b0f5d9880222.jpg",
             "test/downloads/user/atulsvinayak/portraits/e9ff01390cb99a04192f6be9d4418926.jpg",
             "test/downloads/user/atulsvinayak/analog/e9d9bbd0b6470acf543bae48afbfd693.jpg",
             "test/downloads/user/atulsvinayak/analog/3ecd39e41de5885ac6ae2572819d6c45.jpg",
             "test/downloads/user/atulsvinayak/analog/53612d4a297094adbae601dadad7a61f.jpg",
             "test/downloads/user/atulsvinayak/analog/1d5678c38f8ca24fe0c88c7bb5d225f9.jpg",
             "test/downloads/user/atulsvinayak/analog/c699227b5b89f259b184dac4df8c20d7.jpg",
             "test/downloads/user/atulsvinayak/analog/66da7636af01ee0bc507f68c9e23e400.png",
             "test/downloads/user/atulsvinayak/analog/6afca48aca3fd976495e1c14629ad560.png",
             "test/downloads/user/atulsvinayak/analog/8287607906ef4c9ab4b360d20b67bb09.jpg",
             "test/downloads/user/atulsvinayak/analog/24861105f0835aebfa90a396613137d0.jpg",
             "test/downloads/user/atulsvinayak/analog/outdoor/d119db17471e4eff69fdab0af12311ff.jpg",
             "test/downloads/user/atulsvinayak/analog/outdoor/bb245e500788afe263f0c2d6ff0665fa.webp",
             "test/downloads/user/atulsvinayak/analog/outdoor/77ecfdc0bd31b791e8e6278e2be14d9e.jpg",
             "test/downloads/user/atulsvinayak/analog/9482e9b59319d1ea6abb023fbc0c41b0.jpg",
             "test/downloads/user/atulsvinayak/analog/fa48ac8a9a8007c9cfa6262ae2afc673.jpg",
             "test/downloads/user/atulsvinayak/analog/ee3fe16060aedab7a6b41440115fa333.jpg",
             "test/downloads/user/atulsvinayak/analog/2be5535ea5c673c119b240d31279a333.jpg",
             "test/downloads/user/atulsvinayak/analog/f9b2ff0973d7b67f1da6a9c6ff9a90ce.jpg",
             "test/downloads/user/atulsvinayak/analog/2d6db15bafe12c4cb149b668ef9eceb7.jpg",
             "test/downloads/user/atulsvinayak/analog/fff1aff98ce46d9884a9282ed180b330.jpg",
             "test/downloads/user/atulsvinayak/analog/89c873470e85114fe95083176f8113b7.jpg",
             "test/downloads/user/atulsvinayak/analog/f712e1a35058d4ec2c28d0e8bc465907.jpg",
             "test/downloads/user/atulsvinayak/analog/df4ba2cb609d73b014435c1535044860.jpg",
             "test/downloads/user/atulsvinayak/analog/6378cfd740cfbabe02171ae6131c466f.jpg",
             "test/downloads/user/atulsvinayak/analog/eca727875b855c6ae5aec49f41e8ad0f.jpg",
             "test/downloads/user/atulsvinayak/analog/5f3f2fd7b75ec83295f74ef2f5cf1d29.jpg",
             "test/downloads/user/atulsvinayak/analog/de6de741a21d4fd9f629134f4c4ab996.png",
             "test/downloads/user/atulsvinayak/analog/a7b4fa00460d160ace383d6bbe214c15.jpg",
             "test/downloads/user/atulsvinayak/analog/ebc8966acdcd9998b7e748e03952f1da.jpg",
             "test/downloads/user/atulsvinayak/analog/d6370b14649b78e1a51f43a182a300bc.jpg"
           ]

    File.rm_rf!(@download_base)
  end
end
