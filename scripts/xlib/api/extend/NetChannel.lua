function NetChannel.GetPingDelay()
	return NetChannel.GetLatency(Enum.Flow.MAX_FLOWS) * 2 + 0.1
end