require 'celluloid'
Celluloid.task_class = Celluloid::TaskThread
Celluloid.logger = nil

module Photor
  class << self
    # manages a queue of futures so the caller doesn't have to know.
    #
    # the caller is expected to provide a pool of workers (actors), then
    # use a block to enqueue work in the pool (secretly a pool.future).
    #
    # the one klutzy part is that the caller must accept a tracker and
    # pass it return values from the workers.
    #
    #   Photor.work(Actor.pool) do |pool, &tracker|
    #     loop.each do |item|
    #       tracker.call pool.do_something(item)
    #     end
    #   end
    #
    def work(pool, &block)
      stats = {truthy: 0, falsey: 0}
      count = ->(values){
        values.each do |v|
          stats[v ? :truthy : :falsey] += 1
        end
      }

      # TODO: supervisors for fault tolerance?
      futures = []
      block.call(pool.future) do |future|
        futures << future

        while futures.size >= Celluloid.cores * 2
          sleep 0.001 # don't hog CPU with #partition
          ready, futures = futures.partition(&:ready?)
          count.call(ready.map(&:value))
        end
      end
      count.call(futures.map(&:value))

      stats
    end
  end
end
