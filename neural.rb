require 'rmagick'
require 'yaml'
def load_image path
  array = []
  Magick::Image.read(path)[0].resize(30, 30).each_pixel do |pixel, col, row|
    [pixel.red, pixel.green, pixel.blue].each do |c|
      array << (c * 1.0 / 0xffff)
    end
  end
  array
end
def get_set type
  Dir["dataset/#{type}/*/*"].map do |path|
    dataset, train, item, _ = path.split("/")
    [item.to_i,
     load_image(path), path]
  end
end
def evolute neuron, step
  {weights: neuron[:weights].map do |i|
    i += rand > 0.5 ? step : -step
  end}
end
def compute neuron, data
  s = 0
  neuron[:weights].size.times.each { |i| s += data[i] * neuron[:weights][i] }
  s
end
def score neuron, value, data
  s = compute neuron, data
  (value - s) * (value - s)
end
def train neurons, train_set, iterations, step
  threads = []
  neurons.each do |class_value, neuron|
    t = Thread.new do
      last_score = nil
      iterations.times do
        evoluted = evolute neuron, step
        s = train_set.map do |value, data|
          score(evoluted, value == class_value ? 1 : 0, data)
        end.reduce(:+)
        if last_score.nil? or s < last_score
          neuron = evoluted
          last_score = s
        end
      end
      neurons[class_value] = neuron
    end
    threads << t
    t.run
  end
  threads.each { |t| t.join }
end
def run_v neurons, v
    max = -1
    second_max = nil
    result = nil
    neurons.each do |class_value, neuron|
      c = compute(neuron, v)
      if c > max
        second_max = result
        max = c
        result = class_value
      end
    end
    result
end
def run neurons, dataset, verbose = false
  score = 0
  dataset.each do |data|
    expected, v, path = data
    result = run_v neurons, v
    puts "#{path}: #{result}/#{expected}" if verbose
    score += 1 if result == expected
  end
  score = ((score.to_f / dataset.size) * 100).to_i
  puts "==> #{score}" if verbose
  score
end
def get_neurons classes, input_n
  Hash[classes.map { |cv| [cv, { weights: input_n.times.map { 0 } }] }]
end
def load
  return nil if not File.exists? "neurons"
  puts "loading nurons"
  YAML::load(File.read("neurons")) 
end
def backup neurons
  File.write("neurons", neurons.to_yaml)
end
