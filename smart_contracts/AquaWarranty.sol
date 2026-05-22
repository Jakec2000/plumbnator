// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/**
 * @title AquaWarranty
 * @dev Implements an immutable, blockchain-backed warranty registry for plumbing jobs and parts.
 * Ensures transparent records for homeowners, pros, and insurance claims.
 */
contract AquaWarranty {
    
    struct Warranty {
        string propertyId;
        string proId;
        string jobId;
        string partDetails;
        uint256 timestamp;
        uint256 expiryDate;
        bool isActive;
        string ipfsPhotoHash; // Hash to photo proof of repair
    }

    mapping(string => Warranty) public warranties; // jobId => Warranty
    
    event WarrantyIssued(string indexed jobId, string propertyId, string proId, uint256 expiryDate);
    event WarrantyRevoked(string indexed jobId, string reason);

    address public admin;

    constructor() {
        admin = msg.sender;
    }

    modifier onlyAdmin() {
        require(msg.sender == admin, "Only admin can perform this action");
        _;
    }

    function issueWarranty(
        string memory _jobId,
        string memory _propertyId,
        string memory _proId,
        string memory _partDetails,
        uint256 _durationDays,
        string memory _ipfsPhotoHash
    ) public onlyAdmin {
        require(warranties[_jobId].timestamp == 0, "Warranty for this job already exists");

        uint256 expiry = block.timestamp + (_durationDays * 1 days);
        
        warranties[_jobId] = Warranty({
            propertyId: _propertyId,
            proId: _proId,
            jobId: _jobId,
            partDetails: _partDetails,
            timestamp: block.timestamp,
            expiryDate: expiry,
            isActive: true,
            ipfsPhotoHash: _ipfsPhotoHash
        });

        emit WarrantyIssued(_jobId, _propertyId, _proId, expiry);
    }

    function checkWarrantyStatus(string memory _jobId) public view returns (bool) {
        Warranty memory w = warranties[_jobId];
        require(w.timestamp != 0, "Warranty not found");
        return w.isActive && (block.timestamp <= w.expiryDate);
    }

    function revokeWarranty(string memory _jobId, string memory _reason) public onlyAdmin {
        require(warranties[_jobId].timestamp != 0, "Warranty not found");
        warranties[_jobId].isActive = false;
        emit WarrantyRevoked(_jobId, _reason);
    }
}
