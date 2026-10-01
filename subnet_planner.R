# ==============================================================================
# PROJECT: AUTOMATED ENTERPRISE VLSM NETWORK SUBNET PLANNER
# AUTHOR: MATUTUZELA JABULANI NDLOVU (Rex-OG-Kush)
# PURPOSE: Automatically calculates optimized subnet structures minimizing IP waste
#          and exports structural manifest tables to production pipelines.
# ==============================================================================

library(utils)

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
  
  order_idx <- order(host_requirements, decreasing = TRUE)
  sorted_deps <- departments[order_idx]
  sorted_hosts <- host_requirements[order_idx]
  
  current_fourth_octet <- 0
  
  # Initialize a structured data frame matrix to export as a CSV artifact
  blueprint_records <- data.frame(
    Department = character(),
    Hosts_Required = numeric(),
    Address_Pool_Allocated = numeric(),
    CIDR_Prefix = character(),
    Subnet_Mask = character(),
    Network_Address = character(),
    Broadcast_Address = character(),
    Usable_Range = character(),
    Efficiency_Pct = character(),
    stringsAsFactors = FALSE
  )
  
  for (i in 1:length(sorted_deps)) {
    hosts_needed <- sorted_hosts[i]
    host_bits <- calculate_host_bits(hosts_needed)
    subnet_size <- 2^host_bits
    cidr_mask <- 32 - host_bits
    dotted_mask <- cidr_to_dotted_decimal(cidr_mask)
    
    if ((current_fourth_octet + subnet_size) > 256) {
      cat(paste0("🚨 ALLOCATION ALERT: Subnet for '", sorted_deps[i], "' breaks /24 ceiling limits!\n"))
      next
    }
    
    network_addr <- paste0("192.168.1.", current_fourth_octet)
    first_usable <- paste0("192.168.1.", current_fourth_octet + 1)
    last_usable  <- paste0("192.168.1.", current_fourth_octet + subnet_size - 2)
    broadcast    <- paste0("192.168.1.", current_fourth_octet + subnet_size - 1)
    
    allocated_ips <- subnet_size
    efficiency <- round(((hosts_needed + 2) / allocated_ips) * 100, 1)
    
    # Append metrics into the reporting matrix layout
    blueprint_records[nrow(blueprint_records) + 1, ] <- c(
      sorted_deps[i], hosts_needed, allocated_ips, paste0("/", cidr_mask), dotted_mask,
      network_addr, broadcast, paste0(first_usable, " - ", last_usable), paste0(efficiency, "%")
    )
    
    cat(paste0("📍 Department Profile: ", sorted_deps[i], "\n"))
    cat(paste0("   - CIDR Prefix:     /", cidr_mask, " | Mask: ", dotted_mask, "\n"))
    cat(paste0("   - Network Range:   ", network_addr, " -> ", broadcast, " (Yield: ", efficiency, "%)\n\n"))
    
    current_fourth_octet <- current_fourth_octet + subnet_size
  }
  
  # Write findings directly out to a structured CSV delivery artifact
  write.csv(blueprint_records, "network_subnet_blueprint.csv", row.names = FALSE)
  cat("[+] Structural planning blueprint successfully exported: `network_subnet_blueprint.csv`\n")
  cat("======================================================================\n")
}

# Unified CLI Parsing Boundary Interface
args <- commandArgs(trailingOnly = TRUE)
if (length(args) >= 2) {
  # Accepts arguments in format: Rscript subnet_planner.R "DeptA,DeptB" "50,20"
  departments <- unlist(strsplit(args[1], ","))
  host_requirements <- as.numeric(unlist(strsplit(args[2], ",")))
} else {
  # Default robust fallback operational parameters
  departments <- c("Sales Team", "Core Server Infrastructure", "Guest Wi-Fi", "Finance HQ")
  host_requirements <- c(24, 58, 12, 6)
}

plan_network_subnets("192.168.1.0", departments, host_requirements)
