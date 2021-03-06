defmodule PowAssent.HTTPAdapter.MintTest do
  use ExUnit.Case
  doctest PowAssent.HTTPAdapter.Mint

  alias PowAssent.HTTPAdapter.{Mint, HTTPResponse}

  @expired_certificate_url "https://expired.badssl.com"
  @hsts_certificate_url "https://hsts.badssl.com"
  @unreachable_http_url "http://localhost:8888/"

  describe "request/4" do
    test "handles SSL" do
      assert {:ok, %HTTPResponse{status: 200}} = Mint.request(:get, @hsts_certificate_url, nil, [])
      assert {:error, {:tls_alert, 'certificate expired'}} = Mint.request(:get, @expired_certificate_url, nil, [])

      assert {:ok, %HTTPResponse{status: 200}} = Mint.request(:get, @expired_certificate_url, nil, [], transport_opts: [verify: :verify_none])

      assert {:error, :econnrefused} = Mint.request(:get, @unreachable_http_url, nil, [])
    end
  end
end
