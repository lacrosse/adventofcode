require 'time'

def deep_merge(h1, h2)
  h1.merge(h2) { |_, v1, v2| v1.is_a?(Hash) ? deep_merge(v1, v2) : v2 }
end

def each_minute(range)
  time = range.first

  while range.cover?(time)
    yield time
    time += 60
  end
end

def to_array_of_minutes(range)
  a = []

  each_minute(range) { |time| a << time.min }

  a
end

init_guards = Hash.new { |h, k| h[k] = [] }

init_state = {
  guards: init_guards,
  current: {
    id: nil,
    phase_start: nil
  }
}

guards = File.read('input.txt').lines.sort.reduce(init_state) do |state, line|
  timestamp, desc = line.chomp.match(/\A\[(\d{4}-\d{2}-\d{2} \d{2}:\d{2})\] (.+)\z/).captures

  time = Time.parse(timestamp)

  if match = desc.match(/\AGuard #(\d+) begins shift\z/)
    state.merge(current: { id: match[1].to_i, phase_start: time })
  elsif desc == 'falls asleep'
    deep_merge(state, current: { phase_start: time })
  elsif desc == 'wakes up'
    new_guard_state = state[:guards][state[:current][:id]] + [state[:current][:phase_start]...time]
    deep_merge(
      state,
      guards: { state[:current][:id] => new_guard_state },
      current: { phase_start: time }
    )
  else
    raise
  end
end[:guards]

dreamer_id = guards.max_by { |id, asleeps| asleeps.reduce(0) { |sum, asleep| sum + (asleep.last - asleep.first) } }[0]

dreamer_asleeps = guards[dreamer_id]

dreamer_stats = dreamer_asleeps.each_with_object(Hash.new(0)) do |asleep, sum|
  each_minute(asleep) { |time| sum[time.min] += 1 }
end

dreamer_minute = dreamer_stats.max_by { |_, count| count }[0]

puts 'First star:'
puts dreamer_id * dreamer_minute

freq_id, freq_minute, _ = guards.map do |id, asleeps|
  min, count = asleeps.flat_map { |asleep| to_array_of_minutes(asleep) }.group_by(&:itself).map { |k, ls| [k, ls.count] }.max_by { |r| r[1] }
  [id, min, count]
end.max_by { |_, _, count| count }

puts 'Second star:'
puts freq_id * freq_minute
