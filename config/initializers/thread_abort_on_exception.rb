require 'thread'

# Enabling exceptions raising inside threads. Needed by Media, which otherwise
# can't check if its editing subthreads complete with success or not
Thread.abort_on_exception = true
