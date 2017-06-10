# X = {}


# def intense
#   puts "Pid #{Process.pid}"
#   x = 0
#   1000000000.times do |i|
#     x = x + i + Process.pid**4
#   end
#    X["#{Process.pid}"] = Process.pid
#   puts "Pid says #{Process.pid}: #{x}"
#   p X
# end
# puts "master pid #{Process.pid}"


# PIDS = []
# 4.times do 
#   PIDS << fork do 
#     intense
#   end
# end
# Process.waitall

# p X
# p PIDS

def time_forks(num_forks)
  beginning = Time.now
  num_forks.times do 
    fork do
      yield
    end
  end

  Process.waitall
  return Time.now - beginning
end

def time_threads(num_threads)
  beginning = Time.now
  num_threads.times do 
    Thread.new do
      yield
    end
  end

  Thread.list.each do |t|
    t.join if t != Thread.current
  end
  return Time.now - beginning
end

def calculate(cycles)
  x = 0
  cycles.times do
    x += 1 + x**23 + x*1232131423421
  end
end

cycles = 10000000

threaded_seconds = time_threads(2) {  calculate(cycles) }
puts "Threading finished in #{threaded_seconds} seconds"

forked_seconds = time_forks(2) {calculate(cycles) }
puts "Forking finished in #{forked_seconds} seconds"