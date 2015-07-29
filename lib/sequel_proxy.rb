require "sequel_proxy/version"

module SequelProxy
  class ProxyList
    attr_accessor :proxies, :head

    def initialize
      @proxies = []
    end

    def add(proxy)
      @proxies << proxy
    end

    def prepare!
      last = LastProxy.new

      @head = proxies.reverse.inject(last) do |next_proxy_instance, proxy_class|
        instance = proxy_class.new(next_proxy_instance)

        instance
      end
    end

    def self.connection=(connection)
      @@connection = connection
    end
  end

  class Config
    def initialize
      @@proxy_list = ProxyList.new
    end

    def use(proxy)
      @@proxy_list.add(proxy)
    end

    def adapter(adapterClass)
      @@adapter = adapterClass
    end

    def self.proxy_list
      @@proxy_list
    end

    def self.adapter
      @@adapter
    end

    def self.connection
      @@connection
    end

    def self.connection=(connection)
      @@connection = connection
    end
  end

  class BaseProxy
    attr_accessor :next_proxy

    def initialize(next_proxy)
      @next_proxy = next_proxy
    end

    def execute(sql, options=nil, &block)
      next_proxy.execute(sql, options, &block) if next_proxy
    end
  end

  class LastProxy < BaseProxy
    def initialize
    end

    def execute(sql, options=nil, &block)
      Config.connection.execute_without_proxy(sql, options, &block)
    end
  end

  module_function

  def configure
    yield Config.new
  end

  def enable!
    Config.proxy_list.prepare!
    Config.adapter.class_eval do
      def execute_with_proxy(sql, options = nil, &block)
        ::SequelProxy::Config.connection = self
        ::SequelProxy::Config.proxy_list.head.execute(sql, options, &block)
      end

      alias_method :execute_without_proxy, :execute
      alias_method :execute, :execute_with_proxy
    end
  end
end
