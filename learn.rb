require 'neural'
max_score = 0
while true do 
  [400, 500, 1000].each do |iterations|
    [0.005, 0.001, 0.002, 0.003, 0.004].each do |step|
      neurons = max_score == 0 ? load : nil
      train_set = get_set :train
      input_n = train_set[0][1].size
      if not neurons
        classes = train_set.map { |x| x[0] }.uniq
        neurons = get_neurons classes, input_n
        train neurons, train_set, iterations, step
      end
      score0 = run neurons, train_set
      score = run neurons, get_set(:test)
      if score > max_score
        puts "backing up #{score0} #{score} #{iterations} #{step}"
        backup neurons 
        max_score = score
      end
    end
  end
end

