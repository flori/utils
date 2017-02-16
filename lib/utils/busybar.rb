require 'infobar'

class Utils::Busybar
  def initialize(label)
    Infobar(
      total: Float::INFINITY,
      label: label,
      message: { format: ' %l %te %s ', '%s' => { frames: :square1 } }
    )
  end

  def spin
    ib = Thread.new {
      loop do
        +infobar
        sleep 0.1
      end
    }
    t = Thread.new { yield }
    t.join
    ib.kill
    infobar
  end
end
