module TaskinatorUi
  class ProcessDecorator < SimpleDelegator
    STATUS_COLORS = {
      initial: 'primary',
      enqueued: 'primary',
      processing: 'info',
      paused: 'warning',
      resumed: 'warning',
      completed: 'success',
      cancelled: 'warning',
      failed: 'danger',
    }

    def initialize(obj)
      obj = obj.__getobj__ if obj.is_a?(Delegator)
      obj = obj.sub_process if obj.is_a?(Taskinator::Task::SubProcess)

      super(obj.is_a?(Delegator) ? obj.__getobj__ : obj)
    end

    def title
      case __getobj__
      when Taskinator::Task::Step
        "Task <b>#{method}</b>"
      when Taskinator::Task::Job
        "Job <b>#{job}</b>"
      when Taskinator::Process
        "#{__getobj__.class.name.split('::').last}"
      else
        __getobj__.inspect
      end.html_safe
    end

    def html_uuid
      uuid.gsub(':', '').html_safe
    end

    def pending_tasks
      @pending_tasks ||= Taskinator.redis do |conn|
        conn.get("#{key}.pending")
      end
    end

    def status_badge
      "<span class=\"badge bg-#{STATUS_COLORS[current_state]}\">#{current_state}</span>".html_safe
    end

    def class_name
      __getobj__.class.name
    end

    def method
      __getobj__.is_a?(Taskinator::Task::Step) ? __getobj__.method : nil
    end

    def job
      __getobj__.is_a?(Taskinator::Task::Job) ? __getobj__.job : nil
    end
  end
end
