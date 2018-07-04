module Sidekiq
  class Batch
    module WebExtension

      def self.registered(app)
        view_path = File.join(File.expand_path("..", __FILE__), "views")

        app.get "/batches" do
          bids = Sidekiq.redis {|r| r.keys("BID-*") }.map {|x| x.match(/^BID-(.{14})(-jids)?$/); $1 }.uniq.compact
          @batches = bids.map {|x| Sidekiq::Batch::Status.new(x) }.select {|x| x.pending > 0 }
          render(:erb, File.read(File.join(view_path, "batches.erb")))
        end

      end
    end
  end
end
