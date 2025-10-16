import { useCustomers } from "../hooks/useCustomers";

interface CustomerTableProps {
  name: string;
  table: number;
}

export const CustomerTable = () => {
  const { data: customers, isLoading } = useCustomers();

  if (isLoading) {
    return <div className="text-[1.8rem] font-bold">Loading customer data...</div>
  }

  return (
    <div>
      <div className="mt-2 text-[1.5rem] font-semibold text-[#3396D3]">
        Current Customers
      </div>

      <div className="overflow-x-auto">
        <table className="table">
          {/* head */}
          <thead>
            <tr>
              <th></th>
              <th>Name</th>
              <th>Table</th>
            </tr>
          </thead>
          <tbody>
            {customers?.map((customer: CustomerTableProps, i: number) => {
              return (
                <tr key={i}>
                  <th>{i + 1}</th>
                  <td>{customer.name}</td>
                  <td>{customer.table}</td>
                </tr>
              );
            })}
          </tbody>
        </table>
      </div>
    </div>
  );
};
