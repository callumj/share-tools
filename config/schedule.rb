every "0 0-6 * * 1-5" do
  rake "sync"
end

every "2 3,6 * * 1-5" do
  rake "notify"
end