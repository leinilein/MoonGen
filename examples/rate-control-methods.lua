local dpdk		= require "dpdk"
local memory	= require "memory"
local device	= require "device"
local ts		= require "timestamping"
local stats		= require "stats"
local hist		= require "histogram"
local log		= require "log"

local PKT_SIZE	= 60
local ETH_DST	= "11:12:13:14:15:16"

function master(txPort, rate, rc, pattern, threads)
	if not txPort or not rate or not rc or (pattern ~= "cbr" and pattern ~= "poisson") then
		return print("usage: txPort rate hw|moongen cbr|poisson [threads]")
	end
	rate = rate or 2
	threads = threads or 1
	if pattern == "cbr" and threads ~= 1 then
		--return log:error("cbr only supports one thread")
	end
	local txDev = device.config{ port = txPort, txQueues = threads }
	device.waitForLinks()
	for i = 1, threads do
		dpdk.launchLua("loadSlave", txDev:getTxQueue(i - 1), txDev, rate, rc, pattern, i)
	end
	dpdk.waitForSlaves()
end

function loadSlave(queue, txDev, rate, rc, pattern, threadId)
	local mem = memory.createMemPool(function(buf)
		buf:getEthernetPacket():fill{
			ethSrc = txDev,
			ethDst = ETH_DST,
			ethType = 0x1234
		}
	end)
	local bufs = mem:bufArray()
	local txCtr
	if rc == "hw" then
		if pattern ~= "cbr" then
			return log:error("HW only supports CBR")
		end
		txCtr = stats:newDevTxCounter(txDev, "plain")
		queue:setRate(rate * (PKT_SIZE + 4) * 8)
		dpdk.sleepMillis(100) -- for good meaasure
		while dpdk.running() do
			bufs:alloc(PKT_SIZE)
			queue:send(bufs)
			if threadId == 1 then txCtr:update() end
		end
	elseif rc == "moongen" then
		txCtr = stats:newManualTxCounter(txDev, "plain")
		local dist = pattern == "poisson" and poissonDelay or function(x) return x end
		while dpdk.running() do
			bufs:alloc(PKT_SIZE)
			for _, buf in ipairs(bufs) do
				buf:setDelay(dist(10^10 / 8 / (rate * 10^6) - PKT_SIZE - 24))
			end
			txCtr:updateWithSize(queue:sendWithDelay(bufs), PKT_SIZE)
		end
	else
		log:error("Unknown rate control method")
	end
	txCtr:finalize()
end

