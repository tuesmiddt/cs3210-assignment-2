require 'digest'
require 'open3'

if ARGV.length != 3
  puts "Usage: #{$0} num_blocks num_threads input_file"
  exit 1
end

input_file = File.readlines(ARGV[2]).map(&:chomp)

prev_digest = input_file[0].chars.each_slice(2).map(&:join).map { |b| b.to_i(16).chr }.join
target = input_file[1].to_i

stdout, stderr = Open3.capture3("bash -c \"time ./0123HomeWork #{ARGV[0]} #{ARGV[1]} < #{ARGV[2]}\"")
output = stdout.split("\n")

nusnet_id = output[0]
cur_time = [output[1].to_i].pack('L>')
nonce = [output[2].to_i].pack('Q>')
digest = output[3]

input = cur_time + prev_digest + nusnet_id + nonce
correct_digest = Digest::SHA256.hexdigest(input)

to_compare = correct_digest[0..3].to_i(16)

if correct_digest == digest && to_compare < target
  puts "Correct!"
else
  puts "Eeeeee Wrong!"
  puts "Target: #{target}"
  puts "From digest: #{to_compare}"
  puts "Correct digest: #{correct_digest}"
  puts "Given digest: #{digest}"
end
puts stdout
puts stderr
