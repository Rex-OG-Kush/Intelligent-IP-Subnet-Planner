# ==============================================================================
# PROJECT: AUTOMATED ENTERPRISE VLSM NETWORK SUBNET PLANNER
# AUTHOR: MATUTUZELA JABULANI NDLOVU (Rex-OG-Kush)
# PURPOSE: Automatically calculates optimized subnet structures minimizing IP waste
#          and outputs production-ready CIDR and Dotted Decimal notation.
# ==============================================================================

# Helper function to convert CIDR prefix lengths to Dotted Decimal Notation
cidr_to_dotted_decimal <- function(cidr) {
  mask_bits <- c(rep(1, cidr), rep(0, 32 - cidr))
  octets <- numeric(4)
  for (i in 1:4) {
    start_bit <- (i - 1) * 8 + 1
    end_bit <- i * 8
    octets[i] <- sum(mask_bits[start_bit:end_bit] * 2^(7:0))
  }
  return(paste(octets, collapse = "."))
}

# Function to calculate the required host bits for a given number of usable hosts
calculate_host_bits <- function(required_hosts) {
  # Add 2 for network and broadcast addresses
  total_needed <- required_hosts + 2
  bits <- ceiling(log2(total_needed))
  return(bits)
}

# Core Subnetting Simulation Engine
plan_network_subnets <- function(base_ip, departments, host_requirements) {
  cat("======================================================================\n")
  cat("🛡️ ENTERPRISE IPv4 VARIABLE LENGTH SUBNET MASK (VLSM) PLAN\n")
  cat("======================================================================\n")
  cat("Base Network Allocation Perimeter:", base_ip, "/24\n\n")
  
  # Sort requirements in descending order (Standard VLSM Architectural Rule)
  order_idx <- order(host_requirements, decreasing = TRUE)
  sorted_deps <- departments[order_idx]
  sorted_hosts <- host_requirements[order_idx]
  
  # Refactored: Properly tracking the 4th octet host space allocation
  current_fourth_octet <- 0
  
  # Loop through sorted departments to compute addressing schemas
  for (i in 1:length(sorted_deps)) {
    hosts_needed <- sorted_hosts[i]
    host_bits <- calculate_host_bits(hosts_needed)
    subnet_size <- 2^host_bits
    cidr_mask <- 32 - host_bits
    
    # Calculate engineering dotted-decimal equivalent mask parameters
    dotted_mask <- cidr_to_dotted_decimal(cidr_mask)
    
    # Enforce hard upper boundary check constraints on standard Class C bounds
    if ((current_fourth_octet + subnet_size) > 256) {
      cat(paste0("🚨 ALLOCATION ALERT: Subnet for '", sorted_deps[i], "' breaks /24 ceiling layout constraint limits!\n"))
      next
    }
    
    # Calculate precise binary network boundaries
    network_addr <- paste0("192.168.1.", current_fourth_octet)
    first_usable <- paste0("192.168.1.", current_fourth_octet + 1)
    last_usable  <- paste0("192.168.1.", current_fourth_octet + subnet_size - 2)
    broadcast    <- paste0("192.168.1.", current_fourth_octet + subnet_size - 1)
    
    # Calculate IP efficiency metric
    allocated_ips <- subnet_size
    efficiency <- round(((hosts_needed + 2) / allocated_ips) * 100, 1)
    
    # Output the structural breakdown for the admin team
    cat(paste0("📍 Department Profile: ", sorted_deps[i], "\n"))
    cat(paste0("   - Core Metrics:    Required Hosts: ", hosts_needed, " | Allocated Address Pool: ", allocated_ips, "\n"))
    cat(paste0("   - CIDR Prefix:     /", cidr_mask, "\n"))
    cat(paste0("   - Subnet Mask:     ", dotted_mask, "\n"))
    cat(paste0("   - Network Boundaries: ", network_addr, " -> ", broadcast, "\n"))
    cat(paste0("   - Usable Range:    ", first_usable, " to ", last_usable, "\n"))
    cat(paste0("   - Allocation Yield:  ", efficiency, "% Resource Efficiency\n\n"))
    
    # Shift sequentially to the next valid binary network block boundary boundary
    current_fourth_octet <- current_fourth_octet + subnet_size
  }
  cat("======================================================================\n")
}

# Execute the planner with mock corporate structure parameters
departments <- c("Sales Team", "Core Server Infrastructure", "Guest Wi-Fi", "Finance HQ")
host_requirements <- c(24, 58, 12, 6) # Varied structural needs

plan_network_subnets("192.168.1.0", departments, host_requirements)
