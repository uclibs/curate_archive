module ActiveFedora
  module TestCleaner
    extend ActiveSupport::Concern

    included do
      after_create do |obj|
        ActiveFedora::TestCleaner.register(obj)
      end
    end
    module_function

    def setup
      unless ActiveFedora::Base.included_modules.include?(ActiveFedora::TestCleaner)
        ActiveFedora::Base.send(:include, ActiveFedora::TestCleaner)
      end
    end

    def start
      @registry = nil
    end

    def register(obj)
      registry << obj.pid
    end

    def registry
      @registry ||= Set.new
    end

    def clean
      registry.each do |pid|
        ActiveFedora::Base.find(pid, cast: false).delete rescue true
      end
      if registry.size > 0
        solr = ActiveFedora::SolrService.instance.conn
        solr.delete_by_query("*:*", params: {commit: true})
        solr.commit
      end
    ensure
      @registry = nil
    end
  end
end
