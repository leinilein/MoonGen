---------------------------------
--- @file filter_i40e.lua
--- @brief Filter for I40E ...
--- @todo TODO docu
---------------------------------

local mod = {}

local dpdkc		= require "dpdkc"
local device	= require "device"
local ffi		= require "ffi"
local dpdk		= require "dpdk"
local dpdkc		= require "dpdkc"

ffi.cdef[[
enum i40e_status_code {
	I40E_SUCCESS				= 0,
	I40E_ERR_NVM				= -1,
	I40E_ERR_NVM_CHECKSUM			= -2,
	I40E_ERR_PHY				= -3,
	I40E_ERR_CONFIG				= -4,
	I40E_ERR_PARAM				= -5,
	I40E_ERR_MAC_TYPE			= -6,
	I40E_ERR_UNKNOWN_PHY			= -7,
	I40E_ERR_LINK_SETUP			= -8,
	I40E_ERR_ADAPTER_STOPPED		= -9,
	I40E_ERR_INVALID_MAC_ADDR		= -10,
	I40E_ERR_DEVICE_NOT_SUPPORTED		= -11,
	I40E_ERR_MASTER_REQUESTS_PENDING	= -12,
	I40E_ERR_INVALID_LINK_SETTINGS		= -13,
	I40E_ERR_AUTONEG_NOT_COMPLETE		= -14,
	I40E_ERR_RESET_FAILED			= -15,
	I40E_ERR_SWFW_SYNC			= -16,
	I40E_ERR_NO_AVAILABLE_VSI		= -17,
	I40E_ERR_NO_MEMORY			= -18,
	I40E_ERR_BAD_PTR			= -19,
	I40E_ERR_RING_FULL			= -20,
	I40E_ERR_INVALID_PD_ID			= -21,
	I40E_ERR_INVALID_QP_ID			= -22,
	I40E_ERR_INVALID_CQ_ID			= -23,
	I40E_ERR_INVALID_CEQ_ID			= -24,
	I40E_ERR_INVALID_AEQ_ID			= -25,
	I40E_ERR_INVALID_SIZE			= -26,
	I40E_ERR_INVALID_ARP_INDEX		= -27,
	I40E_ERR_INVALID_FPM_FUNC_ID		= -28,
	I40E_ERR_QP_INVALID_MSG_SIZE		= -29,
	I40E_ERR_QP_TOOMANY_WRS_POSTED		= -30,
	I40E_ERR_INVALID_FRAG_COUNT		= -31,
	I40E_ERR_QUEUE_EMPTY			= -32,
	I40E_ERR_INVALID_ALIGNMENT		= -33,
	I40E_ERR_FLUSHED_QUEUE			= -34,
	I40E_ERR_INVALID_PUSH_PAGE_INDEX	= -35,
	I40E_ERR_INVALID_IMM_DATA_SIZE		= -36,
	I40E_ERR_TIMEOUT			= -37,
	I40E_ERR_OPCODE_MISMATCH		= -38,
	I40E_ERR_CQP_COMPL_ERROR		= -39,
	I40E_ERR_INVALID_VF_ID			= -40,
	I40E_ERR_INVALID_HMCFN_ID		= -41,
	I40E_ERR_BACKING_PAGE_ERROR		= -42,
	I40E_ERR_NO_PBLCHUNKS_AVAILABLE		= -43,
	I40E_ERR_INVALID_PBLE_INDEX		= -44,
	I40E_ERR_INVALID_SD_INDEX		= -45,
	I40E_ERR_INVALID_PAGE_DESC_INDEX	= -46,
	I40E_ERR_INVALID_SD_TYPE		= -47,
	I40E_ERR_MEMCPY_FAILED			= -48,
	I40E_ERR_INVALID_HMC_OBJ_INDEX		= -49,
	I40E_ERR_INVALID_HMC_OBJ_COUNT		= -50,
	I40E_ERR_INVALID_SRQ_ARM_LIMIT		= -51,
	I40E_ERR_SRQ_ENABLED			= -52,
	I40E_ERR_ADMIN_QUEUE_ERROR		= -53,
	I40E_ERR_ADMIN_QUEUE_TIMEOUT		= -54,
	I40E_ERR_BUF_TOO_SHORT			= -55,
	I40E_ERR_ADMIN_QUEUE_FULL		= -56,
	I40E_ERR_ADMIN_QUEUE_NO_WORK		= -57,
	I40E_ERR_BAD_IWARP_CQE			= -58,
	I40E_ERR_NVM_BLANK_MODE			= -59,
	I40E_ERR_NOT_IMPLEMENTED		= -60,
	I40E_ERR_PE_DOORBELL_NOT_ENABLED	= -61,
	I40E_ERR_DIAG_TEST_FAILED		= -62,
	I40E_ERR_NOT_READY			= -63,
	I40E_NOT_SUPPORTED			= -64,
	I40E_ERR_FIRMWARE_API_VERSION		= -65,
};

struct i40e_control_filter_stats {
	uint16_t mac_etype_used;   /* Used perfect match MAC/EtherType filters */
	uint16_t etype_used;       /* Used perfect EtherType filters */
	uint16_t mac_etype_free;   /* Un-used perfect match MAC/EtherType filters */
	uint16_t etype_free;       /* Un-used perfect EtherType filters */
};

enum i40e_status_code i40e_aq_add_rem_control_packet_filter(void *hw,
	uint8_t *mac_addr, uint16_t ethtype, uint16_t flags,
	uint16_t vsi_seid, uint16_t queue, bool is_add,
	struct i40e_control_filter_stats *stats,
	struct i40e_asq_cmd_details *cmd_details);
]]

local C = ffi.C

-- FIXME: use DPDK 2.0 filters here
function mod.l2Filter(dev, etype, queue)
	if queue == -1 then
		queue = 511
	end
	local i40eDev = dpdkc.get_i40e_dev(dev.id)
	local vsiSeid = dpdkc.get_i40e_vsi_seid(dev.id)
	assert(C.i40e_aq_add_rem_control_packet_filter(i40eDev, nil, etype, 1 + 4, vsiSeid, queue, true, null, null) == 0)
end

return mod
