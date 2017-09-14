class ThreadProc < Proc

  CLOSE_CONNECTION_PROC = proc {
    # begin
      ActiveRecord::Base.connection.close
    # rescue ActiveRecord::ConnectionTimeoutError
    # end
  }

  def self.new(close_connection_before_execution: false, &block)
    return super(&block) unless block_given?
    
    return super(&block) if block.is_a? self

    if close_connection_before_execution
      super() do
        CLOSE_CONNECTION_PROC.call
        block.call
      end
    else
      super() do
        begin
          block.call
        ensure
          CLOSE_CONNECTION_PROC.call
        end
      end
    end
  end

end
