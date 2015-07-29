require 'spec_helper'

module SequelProxy
  describe ProxyList do
    describe "prepare!" do
      let(:proxy_list) { ProxyList.new }
      subject { proxy_list.prepare! }

      it "creates a list with just a LastProxy instance when no custom proxies are added" do
        subject
        proxy_list.head.must_be_instance_of(LastProxy)
      end

      describe "when more than proxy is added" do
        before do
          class DummyProxy < BaseProxy; end
          class DummyProxy2 < BaseProxy; end
          proxy_list.add(DummyProxy)
          proxy_list.add(DummyProxy2)
        end

        it "creates a list with more elements when more than one proxy is added" do
          subject
          proxy_list.head.must_be_instance_of(DummyProxy)
          proxy_list.head.next_proxy.must_be_instance_of(DummyProxy2)
          proxy_list.head.next_proxy.next_proxy.must_be_instance_of(LastProxy)
        end
      end
    end
  end

  describe BaseProxy do
    describe "#execute" do
      it "if next_proxy is available, calls execute on it" do
        class DummyProxy < BaseProxy
          def execute(sql, options, &block)
            "executed"
          end
        end

        dummy = DummyProxy.new(nil)

        BaseProxy.new(dummy).execute("SELECT * FROM USERS;").must_equal("executed")
      end

      it "if no next_proxy is set, returns nil" do
        BaseProxy.new(nil).execute("SELECT * FROM USERS;").must_be_same_as(nil)
      end
    end
  end

  describe "integration tests" do
    before do
      module Sequel::Dummy; end
      class ::Sequel::Dummy::Database
        def execute(sql, options = nil, &block)
          sql
        end
      end

      class DummyProxy < BaseProxy
        def execute(sql, options = nil, &block)
          if sql =~ /users/
            sql.gsub!('users', 'new_users')
          end
          super
        end
      end

      SequelProxy.configure do |conf|
        conf.adapter ::Sequel::Dummy::Database
        conf.use DummyProxy
      end

      SequelProxy.enable!
    end

    it "runs all configured proxies in order" do
      ::Sequel::Dummy::Database.new.execute("SELECT * FROM users").must_equal("SELECT * FROM new_users")
    end
  end
end
