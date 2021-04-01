# frozen_string_literal: true

require 'k_log'

module KBuilder
  module Logging
    def log
      @log ||= KLog.logger
    end
  end
end
