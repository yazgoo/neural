require_relative 'neural'
neurons = load
dataset = get_set :test
run neurons, dataset, true
