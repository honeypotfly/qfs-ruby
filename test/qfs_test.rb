require 'minitest/autorun'
require 'qfs'

class TestQfs < Minitest::Test
  def initialize(name = nil)
    @test_name = name
    super(name) unless name.nil?
  end

  def setup
    @client = Qfs::Client.new 'qfs0.sea1.qc', 10000
    @file = get_test_path(@test_name)
  end

  def get_test_path(p)
    File.join('/user/ngoldman/test', p)
  end

  def random_data(len = 20)
    (0...len).map { (65 + rand(26)).chr }.join
  end

  def test_open
    data = random_data
    @client.open(@file, 'w+') do |f|
      f.write(data)
    end
    @client.open(@file, 'r') do |f|
      assert_equal(data, f.read(data.length))
    end
  end

  def test_tell
    data = random_data
    @client.open(@file, 'w+') do |f|
      f.write(data)
      assert_equal(data.length, f.tell())
    end
    @client.open(@file, 'w+') do |f|
      assert_equal(0, f.tell())
    end
  end

  def test_remove
    @client.open(@file, 'w') do |f|
      f.write('');
    end
    res = @client.remove(@file)
    assert !@client.exists?(@file)
    assert_equal(1, res)

    assert_raises(Qfs::Error) { @client.remove(@file) }
    assert_equal(0, @client.remove(@file, true))
  end

  def test_exists
    @client.open(@file, 'w') do |f|
      f.write('')
    end
    assert @client.exists?(@file)

    @client.remove(@file)
    assert !@client.exists?(@file)
  end

  def test_mkdir_rmdir
    assert @client.mkdir(@file)
    assert @client.exists?(@file)

    assert_raises(Qfs::Error) { @client.mkdir(@file) }
    assert @client.rmdir(@file)
    assert !@client.exists?(@file)

    assert_raises(Qfs::Error) { @client.rmdir(@file) }
    assert_equal(0, @client.remove(@file, true))
  end

  def test_directory?
    @client.mkdir(@file)
    assert @client.directory?(@file)
    @client.rmdir(@file)

    @client.open(@file, 'w') { |f| f.write('') }
    assert !@client.directory?(@file)
    @client.remove(@file)

    assert !@client.directory?(@file)
  end

  def teardown
    if @client.exists?(@file)
      @client.remove(@file) if @client.file?(@file)
      @client.rmdir(@file) if @client.directory?(@file)
    end
    @client.release
  end
end
