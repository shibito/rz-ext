defmodule BankingWeb.HomeLive do
  use BankingWeb, :live_view

  @init_secret_wordle %{
    first: %{letter: "", match: nil},
    second: %{letter: "", match: nil},
    third: %{letter: "", match: nil},
    forth: %{letter: "", match: nil},
    fifth: %{letter: "", match: nil}
  }

  @impl Phoenix.LiveView
  def mount(_params, _session, socket) do
    socket =
      assign(socket,
        loading: false,
        account_token: %{},
        account_list: [],
        routing: nil,
        selected_account_info: %{},
        secret_wordle: @init_secret_wordle,
        secret_wordle_answered: false,
        secret: nil,
        auth_result: nil,
        auth_transactions: []
      )

    {:ok, socket}
  end

  @impl Phoenix.LiveView
  def render(assigns) do
    ~H"""
    <div class="container mx-auto">
      <div class="flex flex-col space-y-3 md:flex-row md:space-y-0 md:space-x-3 md:justify-center">
        <%!-- Authorized transaction panel --%>
        <div class="p-7 bg-white rounded-lg w-1/4">
          <span :if={@account_token != %{}}>Authorized Transctions</span>

          <div :if={@account_token != %{}}>
            Total: <span class="font-bold">$<%= sum_auth_amount(@auth_transactions) %></span>
          </div>

          <div :for={item <- @auth_transactions} class="">
            <div class="flex flex-col py-2">
              <strong>Company: </strong> <%= item.account["company"] %>
              <strong>Amount: </strong> $<%= item.auth["amount"] %>
            </div>
          </div>

          <button
            :if={@auth_transactions != []}
            class="px-5 py-2 bg-black text-white font-bold"
            type="button"
            phx-click="finalize-transfer"
          >
            Finalize Transfer!
          </button>
        </div>

        <%!-- Actions panel --%>
        <div class="p-7 bg-white rounded-lg w-1/2">
          <div :if={@account_token != %{}}>Account #</div>
          <div class="pb-4">
            <div class="text-lg font-bold select-all"><%= @account_token["account"] %></div>
          </div>

          <div :if={@selected_account_info != %{}}>
            <div>Selected Company</div>
            <div class="px-2">
              <.company_details selected_account_info={@selected_account_info} />
            </div>
          </div>

          <div class="text-center">
            <button
              :if={assigns.account_list == []}
              class="px-16 py-8 text-white font-bold bg-red-500 text-4xl"
              type="button"
              phx-click="start-banking"
            >
              START
            </button>
            <%!-- <button class="px-5 py-2 bg-gray-100" type="button" phx-click="check-state">
              Check State
            </button> --%>
          </div>

          <div :if={assigns.routing} class="flex flex-col space-y-2">
            <form
              id="secret-form"
              phx-submit="authorize"
              class="flex flex-col p-4 mx-auto md:p-5"
              phx-hook="wordleInputFields"
            >
              <div class="flex">
                <input
                  type="text"
                  class={[
                    "w-24 px-2 py-5 m-2 uppercase text-center font-extrabold text-6xl w-secret-input",
                    @secret_wordle.first.match
                  ]}
                  name="first"
                  maxlength="1"
                  value={@secret_wordle.first.letter}
                />
                <input
                  type="text"
                  class={[
                    "w-24 px-2 py-5 m-2 uppercase text-center font-extrabold text-6xl w-secret-input",
                    @secret_wordle.second.match
                  ]}
                  name="second"
                  maxlength="1"
                  value={@secret_wordle.second.letter}
                />
                <input
                  type="text"
                  class={[
                    "w-24 px-2 py-5 m-2 uppercase text-center font-extrabold text-6xl w-secret-input",
                    @secret_wordle.third.match
                  ]}
                  name="third"
                  maxlength="1"
                  value={@secret_wordle.third.letter}
                />
                <input
                  type="text"
                  class={[
                    "w-24 px-2 py-5 m-2 uppercase text-center font-extrabold text-6xl w-secret-input",
                    @secret_wordle.forth.match
                  ]}
                  name="forth"
                  maxlength="1"
                  value={@secret_wordle.forth.letter}
                />
                <input
                  type="text"
                  class={[
                    "w-24 px-2 py-5 m-2 uppercase text-center font-extrabold text-6xl w-secret-input",
                    @secret_wordle.fifth.match
                  ]}
                  name="fifth"
                  maxlength="1"
                  value={@secret_wordle.fifth.letter}
                />
              </div>
              <button
                :if={!@secret_wordle_answered}
                class="px-5 py-2 bg-black text-white font-bold mx-auto text-center"
                type="submit"
              >
                Authorize
              </button>
            </form>

            <div>
              <div>COLOR LEGEND:</div>
            </div>
            <div>
              <div class="exact font-bold p-2 m-2">
                exact: indicates the letter is exactly in the right place in the secret
              </div>
              <div class="word font-bold p-2 m-2">
                word: indicates the secret contains this letter, but in a different place
              </div>
              <div class="none font-bold p-2 m-2">
                none: indicates the secret does not contain that letter
              </div>
              <div class="missing font-bold p-2 m-2">
                missing: indicates that a letter was not provided for this place
              </div>
            </div>
          </div>
        </div>

        <%!-- Transaction Accounts list --%>
        <div class="p-7 bg-white rounded-lg w-1/4">
          <span :if={@account_token != %{}}>Accounts (Highest amount first)</span>

          <%!-- Sort To the highest Amount --%>
          <div class="overflow-auto max-h-screen bg-slate-50">
            <div
              :for={item <- Enum.sort_by(assigns.account_list, & &1["amount"], :desc)}
              :if={assigns.account_list}
              class={[
                "flex flex-col p-2 m-2",
                if(item.authorized, do: "bg-green-100")
              ]}
            >
              <.company_details selected_account_info={item} />
              <div><strong>Transaction Authorized:</strong> <%= item.authorized %></div>
              <button
                :if={!item.authorized}
                class={[
                  "px-5 py-2 font-bold border-2 border-black",
                  if(item.selected, do: "bg-black text-white", else: "bg-gray-100")
                ]}
                type="button"
                phx-click={JS.push("process-account-routing", value: %{account: item})}
                disabled={@loading || item.selected}
              >
                Select: <%= item["company"] %>
              </button>
            </div>
          </div>
        </div>
      </div>

      <div
        :if={@loading}
        class="fixed top-0 left-0 right-0 bottom-0 w-full h-screen z-50 overflow-hidden bg-gray-700 opacity-75 flex flex-col items-center justify-center"
      >
        <div class="loader ease-linear rounded-full border-4 border-t-4 border-gray-200 h-12 w-12 mb-4">
        </div>
        <h2 class="text-center text-white text-xl font-semibold">Loading...</h2>
        <p class="w-1/3 text-center text-white">Please wait...</p>
      </div>
    </div>
    """
  end

  @impl true
  def handle_event("check-state", _, socket) do
    IO.inspect(socket)

    {:noreply, socket}
  end

  # Init fetch token and transaction list
  def handle_event("start-banking", _, socket) do
    send(self(), {:start_banking})

    socket =
      assign(socket,
        loading: true
      )

    {:noreply, socket}
  end

  # Init fetch single account info and state routing
  def handle_event("process-account-routing", %{"account" => account}, socket) do
    send(self(), {:get_routing, account})

    socket =
      assign(socket,
        loading: true,
        secret_wordle_answered: false,
        secret_wordle: @init_secret_wordle
      )

    {:noreply, socket}
  end

  # Init Transaction Authorization trial / error
  def handle_event("authorize", params, socket) do

    first = String.downcase(params["first"])
    second = String.downcase(params["second"])
    third = String.downcase(params["third"])
    forth = String.downcase(params["forth"])
    fifth = String.downcase(params["fifth"])

    socket =
      assign(socket,
        secret_wordle: @init_secret_wordle,
        secret: first <> second <> third <> forth <> fifth,
        loading: true
      )

    send(self(), {:authorize_account})

    {:noreply, socket}
  end

  # Init final fund transfer
  def handle_event("finalize-transfer", _, socket) do
    send(self(), {:finalize_transfer})

    socket =
      assign(socket,
        loading: true
      )

    {:noreply, socket}
  end

  @impl true
  def handle_info({:start_banking}, socket) do
    account_token = BankingCore.refresh_token()
    account_list = BankingCore.list_accounts(account_token["access_token"])

    # Assign account token and transaction list
    socket =
      assign(socket,
        account_token: account_token,
        account_list: account_list,
        loading: false
      )

    {:noreply, socket}
  end

  def handle_info({:get_routing, account}, socket) do

    selected_account_info =
      BankingCore.get_account(socket.assigns.account_token["access_token"], account["account"])

    routing =
      BankingCore.get_routing(
        socket.assigns.account_token["access_token"],
        selected_account_info["account"]["state"]
      )

    # Assign selected account and state routing
    socket =
      assign(socket,
        loading: false,
        selected_account_info: account,
        routing: routing["routing_number"],
        account_list: socket.assigns.account_list |> Enum.map(&select_account_map(&1, account))
      )

    {:noreply, socket}
  end

  def handle_info({:authorize_account}, socket) do
    auth_result =
      BankingCore.authorize(
        socket.assigns.account_token["access_token"],
        socket.assigns.selected_account_info["account"],
        socket.assigns.routing,
        socket.assigns.secret
      )

    {first, _} = auth_result["checks"] |> List.pop_at(0)
    {second, _} = auth_result["checks"] |> List.pop_at(1)
    {third, _} = auth_result["checks"] |> List.pop_at(2)
    {forth, _} = auth_result["checks"] |> List.pop_at(3)
    {fifth, _} = auth_result["checks"] |> List.pop_at(4)

    # Record success authorization
    socket =
      if auth_result["error"] == nil do
        account_list =
          Enum.map(
            socket.assigns.account_list,
            &auth_account_map(&1, socket.assigns.selected_account_info)
          )

        assign(socket,
          secret_wordle_answered: true,
          account_list: account_list,
          auth_transactions:
            socket.assigns.auth_transactions ++
              [%{auth: auth_result, account: socket.assigns.selected_account_info}]
        )
      else
        socket
      end

    socket =
      assign(socket,
        # auth_transactions: socket.assigns.auth_transactions ++ [auth_result],
        auth_result: auth_result,
        loading: false,
        secret_wordle: %{
          first: %{letter: first["letter"], match: first["match"]},
          second: %{letter: second["letter"], match: second["match"]},
          third: %{letter: third["letter"], match: third["match"]},
          forth: %{letter: forth["letter"], match: forth["match"]},
          fifth: %{letter: fifth["letter"], match: fifth["match"]}
        }
      )

    {:noreply, socket}
  end

  def handle_info({:finalize_transfer}, socket) do
    authorization_list = Enum.map(socket.assigns.auth_transactions, fn x -> x.auth["token"] end)

    total_amount =
      sum_auth_amount(socket.assigns.auth_transactions)

    BankingCore.transfer(
      socket.assigns.account_token["access_token"],
      authorization_list,
      total_amount
    )

    socket =
      assign(socket,
        auth_transactions: [],
        loading: false
      )

    {:noreply, socket}
  end

  defp select_account_map(acc_from_map, account) do
    if account["account"] == acc_from_map["account"] do
      %{acc_from_map | selected: true}
    else
      %{acc_from_map | selected: false}
    end
  end

  defp auth_account_map(acc_from_map, account) do
    if account["account"] == acc_from_map["account"] do
      %{acc_from_map | authorized: true}
    else
      acc_from_map
    end
  end

  defp sum_auth_amount(auth_transactions) do
    Enum.reduce(auth_transactions, 0, fn x, acc -> acc + x.auth["amount"] end)
  end
end
