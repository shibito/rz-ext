defmodule BankingCore do
  # @moduledoc """
  # Documentation for `BankingCore`.
  # """

  # @doc """
  # Hello world.

  # ## Examples

  #     iex> BankingCore.hello()
  #     :world

  # """
  # def hello do
  #   :world
  # end

  # TODO: env
  @accounts_endpoint "https://exam.razoyo.com/api/banking/accounts"
  @operation_endpoint "https://exam.razoyo.com/api/banking/operations"
  @client_secret "qRIAKP5ywR5i6sGcv3dFbYDEKoUmV5V5"
  # @client_secret System.get_env("CLIENT_SECRET")

  def refresh_token do
    http_client(
      @accounts_endpoint,
      %{client_secret: @client_secret}
    )
  end

  # list recent transactions
  # Warning: will lock account if exe more than once
  def list_accounts(token_key) do
    http_client(
      @operation_endpoint,
      %{type: "ListTransactions"},
      auth_bearer(token_key)
    )["transactions"]
    |> Enum.map(&append_account_detail(&1))
  end

  # return the account details.
  def get_account(token_key, account_number) do
    http_client(
      @operation_endpoint,
      %{type: "GetAccount", account: account_number},
      auth_bearer(token_key)
    )
  end

  # return the routing number for a state. This value is required to authorize funds.
  def get_routing(token_key, state) do
    http_client(
      @operation_endpoint,
      %{type: "GetRouting", state: state},
      auth_bearer(token_key)
    )
  end

  # authorize funds to be transferred out of this account into yours.
  def authorize(token_key, account_number, routing_number, secret_key) do
    http_client(
      @operation_endpoint,
      %{type: "Authorize", account: account_number, routing: routing_number, secret: secret_key},
      auth_bearer(token_key)
    )
  end

  # transfer authorized funds into your account. This will allow the money to be eligible for withdrawal.
  def transfer(token_key, authorization_list, total_amount) do
    http_client(
      @operation_endpoint,
      %{type: "Transfer", authorizations: authorization_list, total: total_amount},
      auth_bearer(token_key)
    )
  end

  defp http_client(endpoint, request_body, request_header \\ []) do
    result =
      HTTPoison.post!(
        endpoint,
        Jason.encode!(request_body),
        [
          {"Content-Type", "application/json"}
        ] ++ request_header
      )

    Jason.decode!(result.body)
  end

  defp auth_bearer(token_key) do
    [
      {"Authorization", "Bearer #{token_key}"}
    ]
  end

  defp append_account_detail(map) do
    map
    |> Map.put_new(:selected, false)
    |> Map.put_new(:authorized, false)
  end
end
