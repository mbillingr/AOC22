require "./utils/puzzle"

DAY = "07"

raw_data = File.read(__DIR__ + "/../data/input#{DAY}.txt")

Part1.new.check(EXAMPLE, 95437)
Part1.new.run(raw_data)

Part2.new.check(EXAMPLE, 24933642)
Part2.new.run(raw_data)

class Day < Puzzle
  @day = "Day #{DAY}"

  def parse(input)
    input
      .split("\n")
      .select { |x| x != "" }
      .map &.split
  end

  def build_tree(rows, subtree, root)
    cmd = rows.shift

    if matches(cmd, ["$", "cd", "/"])
      return build_tree rows, root, root
    end

    if matches(cmd, ["$", "cd", ".."])
      parent = subtree.parent
      if parent
        return build_tree rows, parent, root
      end
    end

    if matches(cmd, ["$", "cd", :_])
      return build_tree rows, subtree.cd(cmd[2]), root
    end

    if matches(cmd, ["$", "ls"])
      return listing rows, subtree, root
    end

    raise "Unkown command: #{cmd}"
  end

  def listing(rows, subtree, root)
    while rows[0][0] != "$"
      row = rows.shift

      if matches(row, ["dir", :_])
        # ignore
      elsif matches(row, [:_, :_])
        size = row[0].to_i
        name = row[1]
        subtree.touch(name, size)
      else
        raise "Unknown output #{row}"
      end

      if rows.size == 0
        return
      end
    end

    build_tree(rows, subtree, root)
  end

  def matches(inp, ref)
    if inp.size == ref.size
      inp.zip(ref)
        .select { |i, r| r != :_ }
        .map { |i, r| i == r }
        .all?
    end
  end
end

class Part1 < Day
  @part = "Part 1"

  def solve(data)
    root = TDir.new nil
    build_tree data, root, root

    sizes = [] of Int64
    root.cumulative_size(sizes)

    sizes
      .select { |s| s <= 100000 }
      .sum
  end
end

class Part2 < Day
  @part = "Part 2"

  def solve(data)
    root = TDir.new nil
    build_tree data, root, root

    sizes = [] of Int64
    root.cumulative_size(sizes)

    total_space = 70000000
    used_space = sizes.max
    free_space = total_space - used_space
    needed_space = 30000000
    must_free = needed_space - free_space

    sizes.select { |s| s >= must_free }.min
  end
end

class TDir
  getter parent : TDir | Nil
  getter files : Hash(String, Int64)
  getter dirs : Hash(String, TDir)

  def initialize(@parent)
    @dirs = Hash(String, TDir).new
    @files = Hash(String, Int64).new
  end

  def touch(name, size)
    @files[name] = size
  end

  def cd(name)
    dir = @dirs[name]?
    if dir
      dir
    else
      dir = TDir.new self
      @dirs[name] = dir
      dir
    end
  end

  def cumulative_size(sizes) : Int64
    own_size = @files.values.sum
    dir_sizes = @dirs.values.map { |d| d.cumulative_size(sizes) }.sum
    total_size = own_size + dir_sizes
    sizes.push total_size
    total_size
  end
end

EXAMPLE = "$ cd /
$ ls
dir a
14848514 b.txt
8504156 c.dat
dir d
$ cd a
$ ls
dir e
29116 f
2557 g
62596 h.lst
$ cd e
$ ls
584 i
$ cd ..
$ cd ..
$ cd d
$ ls
4060174 j
8033020 d.log
5626152 d.ext
7214296 k
"
